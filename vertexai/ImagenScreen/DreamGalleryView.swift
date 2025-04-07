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

struct DreamGalleryView: View {
    let dreams: [DreamEntry]
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(dreams) { dream in
                    DreamCard(dream: dream)
                        .staggeredAppearanceAnimation(delay: Double(dreams.firstIndex(where: { $0.id == dream.id }) ?? 0) * 0.05)
                }
            }
            .padding(16)
        }
    }
}

struct DreamCard: View {
    let dream: DreamEntry
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Dream image or placeholder
                if let aiImageUrl = dream.aiImageUrl, !aiImageUrl.isEmpty {
                    AsyncImage(url: URL(string: aiImageUrl)) { phase in
                        switch phase {
                        case .empty:
                            dreamCardEmptyView
                        case .success(let image):
                            dreamCardSuccessView(image: image)
                        case .failure:
                            dreamCardFailureView
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 150)
                } else {
                    dreamCardPlaceholderView
                }
                
                // Dream info
                VStack(alignment: .leading, spacing: 4) {
                    Text(dream.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: dream.mood.icon)
                            .foregroundColor(dream.mood.color)
                        
                        Text(dream.date, style: .date)
                            .font(.caption)
                            .foregroundColor(ThemeManager.Colors.textSecondary)
                        
                        Spacer()
                        
                        if dream.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                    .fill(ThemeManager.Materials.thinGlass)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            DreamDetailView(dream: dream)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // Helper views for DreamCard
    private var dreamCardEmptyView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                .fill(ThemeManager.Colors.buttonUnselected)
            ProgressView()
                .tint(.white)
        }
        .aspectRatio(1.3, contentMode: .fill)
    }
    
    private func dreamCardSuccessView(image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium))
    }
    
    private var dreamCardFailureView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                .fill(ThemeManager.Colors.buttonUnselected)
            Image(systemName: "photo.on.rectangle.angled")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
        .aspectRatio(1.3, contentMode: .fill)
    }
    
    private var dreamCardPlaceholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                .fill(ThemeManager.Colors.buttonUnselected)
            Image(systemName: "cloud.moon.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
        .aspectRatio(1.3, contentMode: .fill)
        .frame(height: 150)
    }
}

struct DreamDetailView: View {
    let dream: DreamEntry
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with close and share buttons
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(ThemeManager.Materials.thinGlass))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(ThemeManager.Materials.thinGlass))
                    }
                }
                .padding()
                
                // Image
                if let aiImageUrl = dream.aiImageUrl, !aiImageUrl.isEmpty {
                    AsyncImage(url: URL(string: aiImageUrl)) { phase in
                        switch phase {
                        case .empty:
                            detailEmptyImageView
                        case .success(let image):
                            detailSuccessImageView(image: image)
                        case .failure:
                            detailFailureImageView
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    detailPlaceholderImageView
                }
                
                // Title, Date and Mood
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center) {
                        Text(dream.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: dream.mood.icon)
                                .foregroundColor(dream.mood.color)
                            
                            Text(dream.mood.rawValue.capitalized)
                                .font(.subheadline)
                                .foregroundColor(dream.mood.color)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(dream.mood.color.opacity(0.2))
                        )
                    }
                    
                    Text(dream.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(ThemeManager.Colors.textSecondary)
                    
                    // Description
                    Text(dream.description)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    // Tags
                    if !dream.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(dream.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(ThemeManager.Materials.thinGlass)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    ThemeManager.Colors.pinkPurpleGradientStart,
                    ThemeManager.Colors.pinkPurpleGradientEnd,
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    // Helper views for DreamDetailView
    private var detailEmptyImageView: some View {
        ZStack {
            Rectangle()
                .fill(ThemeManager.Colors.buttonUnselected)
            ProgressView()
                .tint(.white)
        }
        .aspectRatio(16/9, contentMode: .fit)
    }
    
    private func detailSuccessImageView(image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium))
    }
    
    private var detailFailureImageView: some View {
        ZStack {
            Rectangle()
                .fill(ThemeManager.Colors.buttonUnselected)
            Image(systemName: "photo.on.rectangle.angled")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
        .aspectRatio(16/9, contentMode: .fit)
    }
    
    private var detailPlaceholderImageView: some View {
        ZStack {
            Rectangle()
                .fill(ThemeManager.Colors.buttonUnselected)
            Image(systemName: "cloud.moon.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
        .aspectRatio(16/9, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium))
    }
}

#Preview {
    DreamGalleryView(dreams: [
        DreamEntry(
            title: "Flying over mountains",
            description: "I was flying over beautiful snow-capped mountains. The air was crisp and I could see for miles.",
            tags: ["flying", "mountains", "freedom"],
            mood: .peaceful
        ),
        DreamEntry(
            title: "Lost in the forest",
            description: "I was wandering through a dense forest at night, trying to find my way out. I could hear strange noises in the distance.",
            tags: ["forest", "lost", "night"],
            mood: .anxious
        )
    ])
    .background(
        LinearGradient(
            gradient: Gradient(colors: [
                ThemeManager.Colors.pinkPurpleGradientStart,
                ThemeManager.Colors.pinkPurpleGradientEnd,
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    )
} 