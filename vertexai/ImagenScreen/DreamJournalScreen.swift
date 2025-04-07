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

struct DreamJournalScreen: View {
    @StateObject private var viewModel = DreamJournalViewModel()
    @State private var showingNewDreamSheet = false
    @State private var searchActive = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        ThemeManager.Colors.pinkPurpleGradientStart,
                        ThemeManager.Colors.pinkPurpleGradientEnd,
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom header with search
                    HStack {
                        if searchActive {
                            // Search field
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(ThemeManager.Colors.textSecondary)
                                
                                TextField("Search dreams...", text: $viewModel.searchText)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    viewModel.searchText = ""
                                    withAnimation {
                                        searchActive = false
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(ThemeManager.Colors.textSecondary)
                                        .opacity(viewModel.searchText.isEmpty ? 0 : 1)
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                                    .fill(ThemeManager.Materials.thinGlass)
                            )
                        } else {
                            // Title
                            Text("Dream Journal")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Search button
                            Button(action: {
                                withAnimation {
                                    searchActive = true
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(ThemeManager.Materials.thinGlass)
                                    )
                            }
                        }
                    }
                    .padding()
                    .animation(.easeInOut, value: searchActive)
                    
                    // Tab selector
                    HStack(spacing: 0) {
                        TabButton(title: "Gallery", icon: "photo.stack", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        TabButton(title: "Timeline", icon: "calendar", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        
                        TabButton(title: "Favorites", icon: "star.fill", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    // Content based on selected tab
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        Spacer()
                    } else if viewModel.filteredDreams.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "cloud.moon.fill")
                                .font(.system(size: 64))
                                .foregroundColor(ThemeManager.Colors.textSecondary)
                            
                            Text("No dreams recorded yet")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Tap + to add your first dream")
                                .foregroundColor(ThemeManager.Colors.textSecondary)
                                .padding(.top, 4)
                            
                            Button(action: {
                                showingNewDreamSheet = true
                            }) {
                                Label("Add Dream", systemImage: "plus")
                                    .font(.headline)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                                            .fill(ThemeManager.Materials.regularGlass)
                                    )
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                        Spacer()
                    } else {
                        TabView(selection: $selectedTab) {
                            // Gallery View
                            DreamGalleryView(dreams: viewModel.filteredDreams)
                                .tag(0)
                            
                            // Timeline View
                            DreamTimelineView(dreams: viewModel.filteredDreams)
                                .tag(1)
                            
                            // Favorites View
                            DreamGalleryView(dreams: viewModel.filteredDreams.filter { $0.isFavorite })
                                .tag(2)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                }
                
                // FAB for adding new dream
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingNewDreamSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    ThemeManager.Colors.purpleButtonStart,
                                                    ThemeManager.Colors.purpleButtonEnd
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: ThemeManager.Colors.glowColor, radius: 8)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .sheet(isPresented: $showingNewDreamSheet) {
                NewDreamView(viewModel: viewModel)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    // .presentationBackground(.ultraThinMaterial) // iOS 16.4+ only
            }
            .onAppear {
                Task {
                    await viewModel.loadDreams()
                }
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .padding(.vertical, 12)
            .background(
                isSelected ?
                RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                    .fill(ThemeManager.Materials.regularGlass)
                : nil
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DreamJournalScreen()
} 