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

import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct DreamEntry: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var date: Date
    var tags: [String]
    var mood: DreamMood
    var imageUrl: String?
    var aiImageUrl: String?
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         date: Date = Date(),
         tags: [String] = [],
         mood: DreamMood = .neutral,
         imageUrl: String? = nil,
         aiImageUrl: String? = nil,
         isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.tags = tags
        self.mood = mood
        self.imageUrl = imageUrl
        self.aiImageUrl = aiImageUrl
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum DreamMood: String, Codable, CaseIterable {
    case happy
    case peaceful
    case neutral
    case anxious
    case scary
    
    var icon: String {
        switch self {
        case .happy:
            return "face.smiling"
        case .peaceful:
            return "cloud.sun"
        case .neutral:
            return "equal.circle"
        case .anxious:
            return "exclamationmark.triangle"
        case .scary:
            return "theatermasks.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .happy:
            return .yellow
        case .peaceful:
            return .blue
        case .neutral:
            return .gray
        case .anxious:
            return .orange
        case .scary:
            return .red
        }
    }
}

@MainActor
class DreamJournalViewModel: ObservableObject {
    @Published var dreams: [DreamEntry] = []
    @Published var currentDream: DreamEntry?
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var filterTags: [String] = []
    @Published var filterMood: DreamMood?
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Local offline storage
    private let localStorageKey = "dreamJournalEntries"
    
    init() {
        loadLocalDreams()
    }
    
    // MARK: - CRUD Operations
    
    func createDream(title: String, description: String, date: Date, tags: [String], mood: DreamMood, image: UIImage?) async throws {
        isLoading = true
        defer { isLoading = false }
        
        var imageUrl: String?
        
        // Upload user image if present
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.7) {
            let imageName = "\(UUID().uuidString).jpg"
            let storageRef = storage.reference().child("dream_images/\(imageName)")
            
            do {
                _ = try await storageRef.putDataAsync(imageData)
                imageUrl = try await storageRef.downloadURL().absoluteString
            } catch {
                errorMessage = "Failed to upload image: \(error.localizedDescription)"
                throw error
            }
        }
        
        let dream = DreamEntry(
            title: title,
            description: description,
            date: date,
            tags: tags,
            mood: mood,
            imageUrl: imageUrl
        )
        
        // Store in Firestore
        do {
            try await db.collection("dreams").document(dream.id).setData(from: dream)
            await generateAIImage(for: dream)
            dreams.append(dream)
            saveLocalDreams()
        } catch {
            errorMessage = "Failed to save dream: \(error.localizedDescription)"
            throw error
        }
    }
    
    func loadDreams() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await db.collection("dreams").getDocuments()
            let loadedDreams = snapshot.documents.compactMap { document -> DreamEntry? in
                try? document.data(as: DreamEntry.self)
            }
            dreams = loadedDreams
            saveLocalDreams()
        } catch {
            errorMessage = "Failed to load dreams: \(error.localizedDescription)"
            // If online fetch fails, we keep using the local data
        }
    }
    
    func updateDream(_ dream: DreamEntry) async throws {
        isLoading = true
        defer { isLoading = false }
        
        var updatedDream = dream
        updatedDream.updatedAt = Date()
        
        do {
            try await db.collection("dreams").document(dream.id).setData(from: updatedDream)
            
            if let index = dreams.firstIndex(where: { $0.id == dream.id }) {
                dreams[index] = updatedDream
            }
            
            saveLocalDreams()
        } catch {
            errorMessage = "Failed to update dream: \(error.localizedDescription)"
            throw error
        }
    }
    
    func deleteDream(_ dreamId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await db.collection("dreams").document(dreamId).delete()
            dreams.removeAll { $0.id == dreamId }
            saveLocalDreams()
        } catch {
            errorMessage = "Failed to delete dream: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - AI Image Generation
    
    func generateAIImage(for dream: DreamEntry) async {
        guard let index = dreams.firstIndex(where: { $0.id == dream.id }) else { return }
        
        do {
            let imagenViewModel = ImagenViewModel()
            let prompt = "Dream visualization of: \(dream.title). \(dream.description)"
            await imagenViewModel.generateImage(prompt: prompt)
            
            // Wait for images to be generated
            for _ in 0..<10 {
                if !imagenViewModel.images.isEmpty {
                    break
                }
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
            
            // Use the first image if available
            if let firstImage = imagenViewModel.images.first,
               let imageData = firstImage.jpegData(compressionQuality: 0.7) {
                
                let imageName = "\(UUID().uuidString)_ai.jpg"
                let storageRef = storage.reference().child("ai_dream_images/\(imageName)")
                
                _ = try await storageRef.putDataAsync(imageData)
                let downloadUrl = try await storageRef.downloadURL().absoluteString
                
                // Update the dream entry with AI image URL
                var updatedDream = dream
                updatedDream.aiImageUrl = downloadUrl
                
                try await db.collection("dreams").document(dream.id).setData(from: updatedDream)
                dreams[index] = updatedDream
                saveLocalDreams()
            }
        } catch {
            errorMessage = "Failed to generate AI image: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Local Storage
    
    private func saveLocalDreams() {
        if let encoded = try? JSONEncoder().encode(dreams) {
            UserDefaults.standard.set(encoded, forKey: localStorageKey)
        }
    }
    
    private func loadLocalDreams() {
        if let savedDreams = UserDefaults.standard.data(forKey: localStorageKey),
           let decodedDreams = try? JSONDecoder().decode([DreamEntry].self, from: savedDreams) {
            dreams = decodedDreams
        }
    }
    
    // MARK: - Filtering and Searching
    
    var filteredDreams: [DreamEntry] {
        dreams.filter { dream in
            let matchesSearch = searchText.isEmpty || 
                dream.title.localizedCaseInsensitiveContains(searchText) ||
                dream.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesTags = filterTags.isEmpty || 
                filterTags.allSatisfy { tag in dream.tags.contains(tag) }
            
            let matchesMood = filterMood == nil || dream.mood == filterMood
            
            return matchesSearch && matchesTags && matchesMood
        }
    }
} 