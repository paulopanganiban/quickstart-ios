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
import GenerativeAIUIComponents

struct ImagenScreen: View {
  @StateObject var viewModel = ImagenViewModel()

  enum FocusedField: Hashable {
    case message
  }

  @FocusState
  var focusedField: FocusedField?

  var body: some View {
    ZStack {
      // Pink-purple gradient background
      LinearGradient(
        gradient: Gradient(colors: [
          ThemeManager.Colors.pinkPurpleGradientStart,
          ThemeManager.Colors.pinkPurpleGradientEnd
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()
      
      VStack(spacing: 16) {
        // Glass App Header
        GlassAppHeader(title: "Imagen", subtitle: "Create stunning AI-generated images") {
          Button(action: {
            // Add settings or info action here
          }) {
            Image(systemName: "info.circle")
              .font(.title2)
              .foregroundColor(ThemeManager.Colors.textPrimary)
          }
          .buttonStyle(GlassButtonStyle())
        }
        
        // Glass input field
        GlassInputField("Enter a prompt to generate an image", text: $viewModel.userInput, onSubmit: {
          sendOrStop()
        }) {
          Image(
            systemName: viewModel.inProgress ? "stop.circle.fill" : "sparkles"
          )
          .font(.title2)
        }
        .focused($focusedField, equals: .message)
        
        // Glass image grid
        if !viewModel.images.isEmpty {
          GlassImageGrid(images: viewModel.images)
        } else {
          // Empty state with glass effect
          VStack {
            Spacer()
            
            VStack(spacing: 20) {
              Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(ThemeManager.Colors.textSecondary)
              
              Text("Enter a prompt to generate images")
                .font(.headline)
                .foregroundColor(ThemeManager.Colors.textPrimary)
                
              Text("Try something like 'A sunset over mountains' or 'A futuristic city with flying cars'")
                .font(.subheadline)
                .foregroundColor(ThemeManager.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            }
            .padding(30)
            .glassBackground(cornerRadius: ThemeManager.CornerRadius.large)
            .padding()
            
            Spacer()
          }
        }
      }
      .padding(.top)
      
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
