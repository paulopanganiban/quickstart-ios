// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import OSLog
import PhotosUI
import Replicate
import SwiftUI

// Define the PhotoMaker model using the Predictable protocol pattern
enum PhotoMaker: Predictable {
  static var modelID = "tencentarc/photomaker"
  static let versionID = "ddfc2b08d209f9fa8c1eca692712918bd449f695dabb4a958da31802a9570fe4"
  
  // Input struct aligned with the API schema
  struct Input: Codable {
    // Required parameter
    let input_image: String  // URL to an image
    
    // Common parameters
    let prompt: String
    let num_steps: Int
    
    // Optional parameters with defaults
    let style_name: String?
    let negative_prompt: String?
    let num_outputs: Int?
    let style_strength_ratio: Double?
    let guidance_scale: Double?
    let seed: Int?
    
    // Additional input images (optional)
    let input_image2: String?
    let input_image3: String?
    let input_image4: String?
    
    // Safety
    let disable_safety_checker: Bool?
    
    // Custom coding keys to omit nil values
    private enum CodingKeys: String, CodingKey {
      case input_image, prompt, num_steps
      case style_name, negative_prompt, num_outputs
      case style_strength_ratio, guidance_scale, seed
      case input_image2, input_image3, input_image4
      case disable_safety_checker
    }
    
    // Custom encoder that skips nil values
    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      // Required fields
      try container.encode(input_image, forKey: .input_image)
      try container.encode(prompt, forKey: .prompt)
      try container.encode(num_steps, forKey: .num_steps)
      
      // Optional fields - only encode if not nil
      if let style_name = style_name {
        try container.encode(style_name, forKey: .style_name)
      }
      
      if let negative_prompt = negative_prompt {
        try container.encode(negative_prompt, forKey: .negative_prompt)
      }
      
      if let num_outputs = num_outputs {
        try container.encode(num_outputs, forKey: .num_outputs)
      }
      
      if let style_strength_ratio = style_strength_ratio {
        try container.encode(style_strength_ratio, forKey: .style_strength_ratio)
      }
      
      if let guidance_scale = guidance_scale {
        try container.encode(guidance_scale, forKey: .guidance_scale)
      }
      
      if let seed = seed {
        try container.encode(seed, forKey: .seed)
      }
      
      if let input_image2 = input_image2 {
        try container.encode(input_image2, forKey: .input_image2)
      }
      
      if let input_image3 = input_image3 {
        try container.encode(input_image3, forKey: .input_image3)
      }
      
      if let input_image4 = input_image4 {
        try container.encode(input_image4, forKey: .input_image4)
      }
      
      if let disable_safety_checker = disable_safety_checker {
        try container.encode(disable_safety_checker, forKey: .disable_safety_checker)
      }
    }
  }
  
  // The output is an array of image URLs
  typealias Output = [String]
}

@MainActor
class PhotoReasoningViewModelTest: ObservableObject {
  // Replicate API Key - Replace with your own key
  private let client = Replicate.Client(token: "r8_")
  
  // Maximum value for the larger of the two image dimensions (height and width) in pixels.
  private static let largestImageDimension = 768.0

  private var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "generative-ai")

  @Published
  var userInput: String = ""

  @Published
  var selectedItems = [PhotosPickerItem]()

  // Store the processed images from selected items
  private var processedImages = [UIImage]()

  @Published
  var outputText: String? = nil

  @Published
  var generatedImages = [UIImage]()

  @Published
  var errorMessage: String?

  @Published
  var inProgress = false

  @Published
  var isGeneratingImage = false
  
  // Store the current prediction
  @Published
  var prediction: PhotoMaker.Prediction? = nil
  
  // Progress indicator for the prediction (0.0 to 1.0)
  @Published
  var progress: Double = 0.0
  
  // Estimated total time for the prediction in seconds
  private var estimatedTotalTime: Double = 30.0
  
  // Timestamp when prediction started
  private var predictionStartTime: Date?
  
  // Progress update timer
  private var progressTimer: Timer?
  
  // Store the prediction ID separately to avoid actor isolation issues
  private var currentPredictionID: String? = nil

  private var generateImagesTask: Task<Void, Never>?

  init() {
    // No model initialization needed for Replicate
  }

  // Process the selected images and prepare them for submission
  func processSelectedImages() async -> UIImage? {
    processedImages = []
    
    for item in selectedItems {
      do {
        if let data = try await item.loadTransferable(type: Data.self) {
          guard let image = UIImage(data: data) else {
            logger.error("Failed to parse data as an image, skipping.")
            continue
          }
          if image.size.fits(largestDimension: PhotoReasoningViewModelTest.largestImageDimension) {
            processedImages.append(image)
          } else {
            guard
              let resizedImage =
                image
                .preparingThumbnail(
                  of: image.size
                    .aspectFit(largestDimension: PhotoReasoningViewModelTest.largestImageDimension))
            else {
              logger.error("Failed to resize image: \(image)")
              continue
            }

            processedImages.append(resizedImage)
          }
        }
      } catch {
        logger.error("Failed to load image data: \(error.localizedDescription)")
      }
    }
    
    // Return the first processed image or nil if none
    return processedImages.first
  }

  // Transform the image with PhotoMaker
  func transformImage() async {
    inProgress = true
    errorMessage = nil
    outputText = "Processing your image with the prompt: \"\(userInput)\""
    
    // Process selected images
    guard let sourceImage = await processSelectedImages() else {
      errorMessage = "No valid images found"
      inProgress = false
      return
    }
    
    // Start image generation
    await generateImage(sourceImage: sourceImage)
  }

  func generateImage(sourceImage: UIImage) async {
    stop()

    generateImagesTask = Task {
      isGeneratingImage = true
      defer {
        isGeneratingImage = false
        inProgress = false
      }

      do {
        // Use the PhotoMaker model to transform the image
        try await performImageTransformation(sourceImage: sourceImage)
        
      } catch {
        if !Task.isCancelled {
          logger.error("Error generating images: \(error)")
          errorMessage = "Error generating images: \(error.localizedDescription)"
        }
      }
    }
  }

  /// Uses the Replicate PhotoMaker API to transform the image
  private func performImageTransformation(sourceImage: UIImage) async throws {
    // Reset progress
    progress = 0.0
    predictionStartTime = Date()
    
    // For a real implementation, you would convert the image to a URL
    // For example, by uploading it to a storage service and getting a URL back
    
    // For this demo, we're using a placeholder example URL
    let imageUrl = "https://replicate.delivery/pbxt/KFkSv1oX0v3e7GnOrmzULGqCA8222pC6FI2EKcfuCZWxvHN3/newton_0.jpg"
    
    // Create the input object using the API schema
    // Only include the parameters we actually need, don't set anything to nil
    let input = PhotoMaker.Input(
      input_image: imageUrl,
      prompt: userInput,
      num_steps: 50,
      style_name: "Photographic (Default)",
      negative_prompt: "nsfw, lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry",
      num_outputs: 1,
      style_strength_ratio: 20,
      guidance_scale: 5,
      seed: nil,  // Don't pass nil values
      input_image2: nil,  // Don't pass nil values
      input_image3: nil,  // Don't pass nil values
      input_image4: nil,  // Don't pass nil values
      disable_safety_checker: false
    )
    
    // Let's log the input for debugging
    if let inputData = try? JSONEncoder().encode(input),
       let inputString = String(data: inputData, encoding: .utf8) {
      print("API Input: \(inputString)")
    }
    
    // Start progress timer
    startProgressUpdates()
    
    // Create the prediction - store a local copy
    var localPrediction = try await PhotoMaker.predict(with: client, input: input)
    
    // Store the prediction and its ID
    prediction = localPrediction
    currentPredictionID = localPrediction.id
    
    // Wait for the prediction to complete using the local copy
    try await localPrediction.wait(with: client) { updatedPrediction in
      // Update the published property with the latest prediction state
      self.prediction = updatedPrediction
      
      // Update progress based on status
        self.updateProgressFromStatus(updatedPrediction.status.rawValue)
      
      // Log prediction status for debugging
      print("Prediction status: \(updatedPrediction.status)")
      
      // Log output URLs if any (for debugging)
      if let output = updatedPrediction.output {
        print("Output URLs: \(output)")
      }
    }
    
    // Stop progress timer
    stopProgressUpdates()
    
    // Update progress to completion
    progress = 1.0
    
    // Update the stored prediction with the final result
    prediction = localPrediction
    
    // Process the results when prediction completes
    if let urls = localPrediction.output, !urls.isEmpty {
      print("Received \(urls.count) image URLs from API")
      var loadedImages = [UIImage]()
      
      for urlString in urls {
        if Task.isCancelled { break }
        
        if let url = URL(string: urlString) {
          do {
            let data = try Data(contentsOf: url)
            if let image = UIImage(data: data) {
              loadedImages.append(image)
              print("Successfully loaded image from \(urlString)")
            } else {
              print("Could not create UIImage from data at \(urlString)")
            }
          } catch {
            logger.error("Failed to load image from URL: \(error.localizedDescription)")
            print("Error loading image from \(urlString): \(error.localizedDescription)")
          }
        }
      }
      
      if !loadedImages.isEmpty {
        generatedImages = loadedImages
        print("Added \(loadedImages.count) images to generatedImages")
      } else {
        errorMessage = "Could not load generated images"
        print("No images could be loaded from the returned URLs")
        throw NSError(
          domain: "PhotoReasoning", code: 2,
          userInfo: [NSLocalizedDescriptionKey: "Could not load generated images"])
      }
    } else {
      errorMessage = "No images were generated. Please try a different prompt."
      print("API returned empty or nil output array")
      throw NSError(
        domain: "PhotoReasoning", code: 3,
        userInfo: [NSLocalizedDescriptionKey: "No images were generated"])
    }
  }

  func stop() {
    generateImagesTask?.cancel()
    generateImagesTask = nil
    
    // Stop progress updates
    stopProgressUpdates()
    
    // Also cancel the prediction if it's in progress
    if let predictionID = currentPredictionID {
      Task {
        try? await client.cancelPrediction(id: predictionID)
        currentPredictionID = nil
      }
    }
  }
  
  // MARK: - Progress Tracking
  
  private func startProgressUpdates() {
    // Stop any existing timer
    stopProgressUpdates()
    
    // Reset progress
    progress = 0.0
    predictionStartTime = Date()
    
    // Create a timer to update progress
    DispatchQueue.main.async {
      self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
        self?.updateProgressBasedOnTime()
      }
    }
  }
  
  private func stopProgressUpdates() {
    DispatchQueue.main.async {
      self.progressTimer?.invalidate()
      self.progressTimer = nil
    }
  }
  
  private func updateProgressBasedOnTime() {
    guard let startTime = predictionStartTime else { return }
    
    let elapsedTime = Date().timeIntervalSince(startTime)
    let calculatedProgress = min(elapsedTime / estimatedTotalTime, 0.95)
    
    // Only update if the new progress is greater (to avoid going backwards)
    if calculatedProgress > progress {
      progress = calculatedProgress
    }
  }
  
  private func updateProgressFromStatus(_ status: String) {
    switch status {
    case "starting":
      progress = 0.1
    case "processing":
      // Only update if the current progress is less than this threshold
      if progress < 0.2 {
        progress = 0.2
      }
    case "succeeded":
      progress = 1.0
      stopProgressUpdates()
    case "failed", "canceled":
      stopProgressUpdates()
    default:
      // Unknown status, do nothing special
      break
    }
  }
}

extension CGSize {
  fileprivate func fits(largestDimension length: CGFloat) -> Bool {
    return width <= length && height <= length
  }

  fileprivate func aspectFit(largestDimension length: CGFloat) -> CGSize {
    let aspectRatio = width / height
    if width > height {
      let width = min(self.width, length)
      return CGSize(width: width, height: round(width / aspectRatio))
    } else {
      let height = min(self.height, length)
      return CGSize(width: round(height * aspectRatio), height: height)
    }
  }
}

