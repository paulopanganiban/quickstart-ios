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

import GenerativeAIUIComponents
import SwiftUI

struct ImagenScreen: View {
  @StateObject var viewModel = ImagenViewModel()

  enum FocusedField: Hashable {
    case message
  }

  @FocusState
  var focusedField: FocusedField?

  var body: some View {
    NavigationStack {
      ZStack {
        backgroundGradient
        mainContent
        
        // Glass progress overlay
        if viewModel.inProgress {
          GlassProgressOverlay()
        }
      }
      .navigationBarHidden(true)
      .onAppear {
        focusedField = .message
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
  
  private var mainContent: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 24) {
        // Glass App Header
        GlassAppHeader(title: "Imagen", subtitle: "Create stunning AI-generated images")
        
        promptInputSection
        
        imageResultsSection
      }
      .padding(.top)
    }
    .scrollDismissesKeyboard(.immediately)
  }
  
  private var promptInputSection: some View {
    HStack(spacing: 12) {
      // Text field with glass effect
      TextField("", text: $viewModel.userInput)
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .foregroundColor(.white)
        .placeholder(when: viewModel.userInput.isEmpty) {
          Text("Enter a prompt to generate an image")
            .foregroundColor(ThemeManager.Colors.textSecondary)
            .padding(.horizontal, 20)
        }
        .background(
          RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
            .fill(ThemeManager.Materials.thinGlass)
        )
        .focused($focusedField, equals: .message)
        .onSubmit { sendOrStop() }
      
      // Sparkle button with clean look and no glow effects
      Button(action: {
        sendOrStop()
      }) {
        Image(systemName: viewModel.inProgress ? "stop.circle.fill" : "sparkles")
          .font(.system(size: 22, weight: .medium))
          .iconGradient()
      }
      .buttonStyle(GlowingButtonStyle())
    }
    .padding(.horizontal)
  }
  
  private var imageResultsSection: some View {
    Group {
      if !viewModel.images.isEmpty {
        GlassImageGrid(images: viewModel.images)
          .padding(.top, 8)
      } else {
        emptyStateView
      }
    }
  }
  
  private var emptyStateView: some View {
    VStack {
      Spacer()
        .frame(height: 40) // Add some space at the top of empty state
      
      VStack(spacing: 20) {
        Image(systemName: "photo.on.rectangle.angled")
          .font(.system(size: 60))
          .foregroundColor(ThemeManager.Colors.textSecondary)
        
        Text("Enter a prompt to generate images")
          .font(.headline)
          .foregroundColor(ThemeManager.Colors.textPrimary)
        
        Text(
          "Try something like 'A sunset over mountains' or 'A futuristic city with flying cars'"
        )
        .font(.subheadline)
        .foregroundColor(ThemeManager.Colors.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
      }
      .padding(20)
      .glassBackground(cornerRadius: ThemeManager.CornerRadius.large)
      .padding()
      
      Spacer()
        .frame(minHeight: 40) // Add some space at the bottom of empty state
    }
  }

  private func sendMessage() {
    Task {
      await viewModel.generateImage(prompt: viewModel.userInput)
      focusedField = .message
    }
  }

  private func sendOrStop() {
    if viewModel.inProgress {
      viewModel.stop()
    } else {
      sendMessage()
    }
  }
}

#Preview {
  ImagenScreen()
}
