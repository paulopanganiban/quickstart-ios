// Copyright 2025 Google LLC
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

import SwiftUI
import PhotosUI

struct NewDreamView: View {
    @ObservedObject var viewModel: DreamJournalViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var tagInput: String = ""
    @State private var tags: [String] = []
    @State private var mood: DreamMood = .neutral
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isGeneratingImage: Bool = false
    @State private var showDatePicker: Bool = false
    @StateObject private var imagenViewModel = ImagenViewModel()
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    imagePickerSection
                    titleSection
                    aiImageSection
                    dateSection
                    moodSection
                    tagsSection
                    descriptionSection
                    saveButtonSection
                }
                .padding()
            }
        }
    }
    
    // MARK: - Helper Views
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                ThemeManager.Colors.pinkPurpleGradientStart,
                ThemeManager.Colors.pinkPurpleGradientEnd,
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        HStack {
            Text("New Dream")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(ThemeManager.Materials.thinGlass))
            }
        }
    }
    
    private var imagePickerSection: some View {
        VStack {
            if let selectedImage = selectedImage {
                selectedImageView(image: selectedImage)
            } else {
                photoPickerButton
            }
        }
    }
    
    private func selectedImageView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium))
            .overlay(
                Button(action: {
                    self.selectedImage = nil
                    self.selectedItem = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .padding(8),
                alignment: .topTrailing
            )
    }
    
    private var photoPickerButton: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            ZStack {
                RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                    .fill(ThemeManager.Materials.thinGlass)
                    .frame(height: 120)
                
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    
                    Text("Add Image")
                        .foregroundColor(.white)
                }
            }
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                TextField("", text: $title)
                    .placeholder(when: title.isEmpty) {
                        Text("Give your dream a title")
                            .foregroundColor(ThemeManager.Colors.textSecondary)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                            .fill(ThemeManager.Materials.thinGlass)
                    )
                
                // AI Generation Button
                Button(action: {
                    generateAIImage()
                }) {
                    Image(systemName: imagenViewModel.inProgress ? "stop.circle.fill" : "sparkles")
                        .font(.system(size: 22, weight: .medium))
                        .iconGradient()
                }
                .buttonStyle(GlowingButtonStyle())
                .disabled(title.isEmpty)
                .opacity(title.isEmpty ? 0.6 : 1)
            }
        }
    }
    
    // New AI Image Results Section
    private var aiImageSection: some View {
        Group {
            if !imagenViewModel.images.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Generated Images")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    GlassImageGrid(images: imagenViewModel.images)
                }
            }
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date")
                .font(.headline)
                .foregroundColor(.white)
            
            Button(action: {
                withAnimation {
                    showDatePicker.toggle()
                }
            }) {
                HStack {
                    Text(date, style: .date)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                        .fill(ThemeManager.Materials.thinGlass)
                )
            }
            
            if showDatePicker {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .background(
                        RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                            .fill(ThemeManager.Materials.regularGlass)
                    )
                    .tint(ThemeManager.Colors.accentColor)
                    .padding(.top, 8)
            }
        }
    }
    
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood")
                .font(.headline)
                .foregroundColor(.white)
            
                HStack(spacing: 12) {
                    ForEach(DreamMood.allCases, id: \.self) { currentMood in
                        moodButton(for: currentMood)
                    }
                }        }
    }
    
    private func moodButton(for currentMood: DreamMood) -> some View {
        Button(action: {
            mood = currentMood
        }) {
            VStack(spacing: 8) {
                Image(systemName: currentMood.icon)
                    .font(.system(size: 24))
                    .foregroundColor(currentMood == mood ? .white : currentMood.color)
                
                Text(currentMood.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(currentMood == mood ? .white : ThemeManager.Colors.textSecondary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                moodBackgroundView(for: currentMood)
            )
        }
    }
    
    @ViewBuilder
    private func moodBackgroundView(for currentMood: DreamMood) -> some View {
        if currentMood == mood {
            // Selected mood - use color background
            RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                .fill(currentMood.color.opacity(0.8))
        } else {
            // Unselected mood - use glass material
            RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                .fill(ThemeManager.Materials.thinGlass)
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                TextField("", text: $tagInput)
                    .placeholder(when: tagInput.isEmpty) {
                        Text("Add tags separated by comma")
                            .foregroundColor(ThemeManager.Colors.textSecondary)
                    }
                    .foregroundColor(.white)
                    .submitLabel(.done)
                    .onSubmit {
                        addTags()
                    }
                
                Button(action: {
                    addTags()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                    .fill(ThemeManager.Materials.thinGlass)
            )
            
            // Tag list
            if !tags.isEmpty {
                tagListView
            }
        }
    }
    
    private var tagListView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    tagView(for: tag)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func tagView(for tag: String) -> some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.subheadline)
                .foregroundColor(.white)
            
            Button(action: {
                tags.removeAll { $0 == tag }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(ThemeManager.Materials.regularGlass)
        )
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.white)
            
            TextEditor(text: $description)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                        .fill(ThemeManager.Materials.thinGlass)
                )
                .frame(minHeight: 120)
                .overlay(
                    Group {
                        if description.isEmpty {
                            Text("Describe your dream...")
                                .foregroundColor(ThemeManager.Colors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 10)
                                .allowsHitTesting(false)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                )
        }
    }
    
    private var saveButtonSection: some View {
        Button(action: {
            saveDream()
        }) {
            HStack {
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Save Dream")
                        .font(.headline)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                ThemeManager.Colors.purpleButtonStart,
                                ThemeManager.Colors.purpleButtonEnd
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .foregroundColor(.white)
        }
        .disabled(title.isEmpty || description.isEmpty || viewModel.isLoading)
        .opacity((title.isEmpty || description.isEmpty || viewModel.isLoading) ? 0.6 : 1)
    }
    
    private func addTags() {
        let newTags = tagInput
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        for tag in newTags {
            if !tags.contains(tag) {
                tags.append(tag)
            }
        }
        
        tagInput = ""
    }
    
    private func saveDream() {
        Task {
            do {
                try await viewModel.createDream(
                    title: title,
                    description: description,
                    date: date,
                    tags: tags,
                    mood: mood,
                    image: selectedImage
                )
                dismiss()
            } catch {
                // Error is already displayed in the viewModel
            }
        }
    }
    
    // New function to generate AI images
    private func generateAIImage() {
        if imagenViewModel.inProgress {
            imagenViewModel.stop()
        } else if !title.isEmpty {
            let prompt = "Dream scene: \(title)"
            Task {
                await imagenViewModel.generateImage(prompt: prompt)
                
                // If images were generated and we have no selected image yet, 
                // use the first AI image as the selected image
                if !imagenViewModel.images.isEmpty && selectedImage == nil {
                    selectedImage = imagenViewModel.images.first
                }
            }
        }
    }
}

#Preview {
    NewDreamView(viewModel: DreamJournalViewModel())
} 