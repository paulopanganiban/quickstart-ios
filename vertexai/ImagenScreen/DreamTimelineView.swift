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

struct DreamTimelineView: View {
    let dreams: [DreamEntry]
    
    // Group dreams by month and year
    var groupedDreams: [String: [DreamEntry]] {
        return groupDreamsByMonthAndYear(dreams)
    }
    
    // Sort keys by most recent
    var sortedKeys: [String] {
        return sortMonthYearKeysByRecency(groupedDreams.keys)
    }
    
    // Helper function to group dreams
    private func groupDreamsByMonthAndYear(_ dreamList: [DreamEntry]) -> [String: [DreamEntry]] {
        let sortedDreams = dreamList.sorted(by: { $0.date > $1.date })
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        return Dictionary(grouping: sortedDreams) { dream in
            return dateFormatter.string(from: dream.date)
        }
    }
    
    // Helper function to sort month-year keys
    private func sortMonthYearKeysByRecency(_ keys: Dictionary<String, [DreamEntry]>.Keys) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        return keys.sorted { key1, key2 in
            guard let date1 = dateFormatter.date(from: key1),
                  let date2 = dateFormatter.date(from: key2) else {
                return false
            }
            return date1 > date2
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(sortedKeys, id: \.self) { key in
                    VStack(alignment: .leading, spacing: 16) {
                        // Month header
                        Text(key)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        // Dreams for this month
                        ForEach(groupedDreams[key] ?? []) { dream in
                            TimelineDreamCard(dream: dream)
                                .staggeredAppearanceAnimation(delay: 0.1)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct TimelineDreamCard: View {
    let dream: DreamEntry
    @State private var showDetail = false
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: dream.date)
    }
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: dream.date)
    }
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            HStack(alignment: .center, spacing: 16) {
                // Date circle
                VStack {
                    Text(formattedDate)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(dayOfWeek)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(ThemeManager.Materials.regularGlass)
                )
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(dream.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: dream.mood.icon)
                            .foregroundColor(dream.mood.color)
                    }
                    
                    Text(dream.description)
                        .font(.subheadline)
                        .foregroundColor(ThemeManager.Colors.textSecondary)
                        .lineLimit(2)
                    
                    // Tags
                    if !dream.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(dream.tags.prefix(3), id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(ThemeManager.Materials.thinGlass)
                                        )
                                }
                                
                                if dream.tags.count > 3 {
                                    Text("+\(dream.tags.count - 3) more")
                                        .font(.caption)
                                        .foregroundColor(ThemeManager.Colors.textSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
                
                // Dream image (small thumbnail)
                if let aiImageUrl = dream.aiImageUrl, !aiImageUrl.isEmpty {
                    AsyncImage(url: URL(string: aiImageUrl)) { phase in
                        switch phase {
                        case .empty:
                            emptyImageView
                        case .success(let image):
                            successImageView(image: image)
                        case .failure:
                            failureImageView
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 60, height: 60)
                } else {
                    placeholderImageView
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                    .fill(ThemeManager.Materials.thinGlass)
                    .padding(.horizontal)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            DreamDetailView(dream: dream)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // Helper views to break down complex expressions
    private var emptyImageView: some View {
        Color.clear
            .frame(width: 60, height: 60)
            .background(ThemeManager.Colors.buttonUnselected)
            .clipShape(RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.small))
    }
    
    private func successImageView(image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.small))
    }
    
    private var failureImageView: some View {
        Image(systemName: "photo.on.rectangle.angled")
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(ThemeManager.Colors.buttonUnselected)
            .clipShape(RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.small))
    }
    
    private var placeholderImageView: some View {
        Image(systemName: "cloud.moon.fill")
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(ThemeManager.Colors.buttonUnselected)
            .clipShape(RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.small))
    }
}

#Preview {
    DreamTimelineView(dreams: [
        DreamEntry(
            title: "Flying over mountains",
            description: "I was flying over beautiful snow-capped mountains. The air was crisp and I could see for miles.",
            date: Date(),
            tags: ["flying", "mountains", "freedom"],
            mood: .peaceful
        ),
        DreamEntry(
            title: "Lost in the forest",
            description: "I was wandering through a dense forest at night, trying to find my way out. I could hear strange noises in the distance.",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            tags: ["forest", "lost", "night"],
            mood: .anxious
        ),
        DreamEntry(
            title: "Ocean adventure",
            description: "I was swimming deep in the ocean, discovering colorful coral reefs and friendly sea creatures.",
            date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
            tags: ["ocean", "swimming", "adventure"],
            mood: .happy
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