//
//  ImageListViewModel.swift
//  LightspeedMobileTest
//
//  Created by Andrew So on 2025-08-22.
//
//  Purpose:
//    Acts as a store for managing a list of ImageItem objects.
//    Handles fetching random images from the API, persisting them locally,
//    and supporting list operations like add, delete, and reorder.
//
//  Notes:
//    - Annotated with @MainActor to ensure UI updates happen on the main thread.
//    - Uses StorageManager for persistence and APIService for fetching images.
//    - Changes to `items` are published automatically for SwiftUI views.
//

import Foundation

@MainActor
final class ImageListStore: ObservableObject {
    
    // The list of images currently managed by the store.
    @Published private(set) var items: [ImageItem] = []
    
    // Service for fetching images from the Picsum API.
    private let api = APIService()
    
    // Manager for persisting images locally using UserDefaults.
    private let storage = StorageManager()
    
    // Initializes the store by loading any saved images from persistence.
    init() {
        items = storage.load()
    }
    
    // Fetches a list of images and attempts to add a new unique random image.
    // Returns: An optional ImageItem that was added, or nil if none were added.
    // Throws:  Errors from APIService.fetchImages(), such as network or decoding errors.
    @discardableResult
    func addRandomImage() async throws -> ImageItem? {
        let all = try await api.fetchImages()
        guard !all.isEmpty else {
            return nil
        }
        
        for _ in 0..<10 {
            if let pick = all.randomElement(),
               items.contains(where: { $0.id == pick.id }) == false {
                items.append(pick)
                storage.save(items)
                return pick
            }
        }
        return nil
    }
    
    // Deletes images at the given offsets and saves the updated list.
    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        storage.save(items)
    }
    
    // Moves images from the source indices to the destination index, then saves.
    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        storage.save(items)
    }
    
    // Removes all images and saves the empty list.
    func deleteAll() {
        items.removeAll()
        storage.save(items)
    }
}
