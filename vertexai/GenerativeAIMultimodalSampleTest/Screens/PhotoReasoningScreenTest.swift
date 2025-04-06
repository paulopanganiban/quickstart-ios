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

import GenerativeAIUIComponents
import MarkdownUI
import PhotosUI
import SwiftUI
import Replicate

struct PhotoReasoningScreenTest: View {
  @StateObject var viewModel = PhotoReasoningViewModelTest()

  enum FocusedField: Hashable {
    case message
  }

  @FocusState
  var focusedField: FocusedField?

  var body: some View {
    VStack {
      inputField
      messageList
    }
    .navigationTitle("PhotoMaker with Replicate")
    .onAppear {
      focusedField = .message
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        resetButton
      }
    }
  }
  
  private var inputField: some View {
    MultimodalInputField(text: $viewModel.userInput, selection: $viewModel.selectedItems)
      .focused($focusedField, equals: .message)
      .onSubmit {
        onSendTapped()
      }
  }
  
  private var messageList: some View {
    ScrollViewReader { scrollViewProxy in
      List {
        aiAnalysisSection
        
        if viewModel.isGeneratingImage {
          generationProgressSection
        }
        
        if let prediction = viewModel.prediction {
          predictionStatusSection(prediction)
        }
        
        if !viewModel.generatedImages.isEmpty {
          generatedImagesSection
        }
        
        if viewModel.isGeneratingImage {
          loadingIndicatorSection
        }
        
        if let errorMessage = viewModel.errorMessage {
          errorMessageSection(errorMessage)
        }
      }
      .listStyle(.insetGrouped)
    }
  }
  
  private var aiAnalysisSection: some View {
    Section(header: Text("AI ANALYSIS")) {
      if viewModel.inProgress {
        loadingView
      } else if let outputText = viewModel.outputText, !outputText.isEmpty {
        outputView(outputText)
      } else if !viewModel.selectedItems.isEmpty {
        emptyAnalysisView
      } else {
        instructionView
      }
    }
  }
  
  private var loadingView: some View {
    HStack {
      Spacer()
      ProgressView()
        .scaleEffect(1.2)
        .padding()
      Spacer()
    }
  }
  
  private func outputView(_ text: String) -> some View {
    HStack(alignment: .top) {
      Image(systemName: "cloud.circle.fill")
        .font(.title2)
        .foregroundColor(.blue)
        .padding(.top, 4)
      
      Markdown("\(text)")
        .markdownTheme(.basic)
        .padding(.vertical, 4)
    }
  }
  
  private var emptyAnalysisView: some View {
    HStack {
      Spacer()
      Text("Analysis will appear here")
        .foregroundColor(.secondary)
        .font(.callout)
        .padding()
      Spacer()
    }
  }
  
  private var instructionView: some View {
    HStack {
      Spacer()
      Text("Add an image and ask a question")
        .foregroundColor(.secondary)
        .font(.callout)
        .padding()
      Spacer()
    }
  }
  
  private var generationProgressSection: some View {
    Section(header: Text("GENERATION PROGRESS")) {
      VStack(spacing: 12) {
        ProgressView(value: viewModel.progress, total: 1.0)
          .progressViewStyle(LinearProgressViewStyle())
          .tint(.blue)
          .scaleEffect(x: 1, y: 1.5, anchor: .center)
        
        HStack {
          Text("\(Int(viewModel.progress * 100))%")
            .font(.caption)
            .foregroundColor(.secondary)
          
          Spacer()
          
          if let predStatus = viewModel.prediction?.status {
              Text("Status: \(statusText(predStatus.rawValue))")
              .font(.caption)
              .foregroundColor(statusColor(predStatus.rawValue))
          } else {
            Text("Preparing...")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      }
      .padding(.vertical, 8)
    }
  }
  
  private func predictionStatusSection(_ prediction: Prediction<PhotoMaker.Input, PhotoMaker.Output>) -> some View {
    Section(header: Text("PREDICTION STATUS")) {
      HStack {
        Text("Status:")
          .fontWeight(.medium)
        
        switch prediction.status.rawValue {
        case "starting":
          Text("Starting")
            .foregroundColor(.orange)
        case "processing":
          Text("Processing")
            .foregroundColor(.blue)
        case "succeeded":
          Text("Succeeded")
            .foregroundColor(.green)
        case "failed":
          Text("Failed")
            .foregroundColor(.red)
        case "canceled":
          Text("Canceled")
            .foregroundColor(.gray)
        default:
          Text(prediction.status.rawValue)
            .foregroundColor(.gray)
        }
        
        Spacer()
        
        if prediction.status.rawValue == "processing" || prediction.status.rawValue == "starting" {
          ProgressView()
            .scaleEffect(0.8)
        }
      }
      .padding(.vertical, 4)
    }
  }
  
  private var generatedImagesSection: some View {
    Section(header: Text("GENERATED IMAGES")) {
      let spacing: CGFloat = 10
      LazyVGrid(columns: [
        GridItem(.flexible(), spacing: spacing),
        GridItem(.flexible(), spacing: spacing),
      ], spacing: spacing) {
        ForEach(Array(viewModel.generatedImages.enumerated()), id: \.offset) { index, image in
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minHeight: 150)
            .cornerRadius(12)
            .clipped()
        }
      }
      .padding(.horizontal, spacing)
      .listRowInsets(EdgeInsets())
    }
  }
  
  private var loadingIndicatorSection: some View {
    Section {
      HStack {
        Spacer()
        VStack {
          ProgressView()
            .scaleEffect(1.5)
            .padding()
          Text("Generating images...")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        Spacer()
      }
      .frame(height: 100)
    }
  }
  
  private func errorMessageSection(_ errorMessage: String) -> some View {
    Section {
      Text(errorMessage)
        .foregroundColor(.red)
        .font(.caption)
    }
  }
  
  private var resetButton: some View {
    Button(action: {
      viewModel.stop()
      viewModel.generatedImages = []
      viewModel.outputText = nil
      viewModel.errorMessage = nil
      focusedField = .message
    }) {
      Image(systemName: "arrow.clockwise.circle")
        .font(.title3)
    }
    .disabled(viewModel.inProgress || viewModel.isGeneratingImage)
  }

  // MARK: - Helper methods
  
  private func statusText(_ status: String) -> String {
    switch status {
    case "starting":
      return "Initializing"
    case "processing":
      return "Processing"
    case "succeeded":
      return "Completed"
    case "failed":
      return "Failed"
    case "canceled":
      return "Canceled"
    default:
      return status
    }
  }
  
  private func statusColor(_ status: String) -> Color {
    switch status {
    case "starting":
      return .orange
    case "processing":
      return .blue
    case "succeeded":
      return .green
    case "failed":
      return .red
    case "canceled":
      return .gray
    default:
      return .secondary
    }
  }

  // MARK: - Actions

  private func onSendTapped() {
    focusedField = nil

    Task {
      await viewModel.transformImage()
    }
  }
}

#Preview {
  NavigationStack {
    PhotoReasoningScreenTest()
  }
}
