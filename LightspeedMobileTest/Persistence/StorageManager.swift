//
//  StorageManager.swift
//  LightspeedMobileTest
//
//  Created by Andrew So on 2025-08-22.
//
//  Purpose:
//    Provides functionality to save and load an array of ImageItem objects
//    using UserDefaults as a lightweight persistence layer.
//    Intended for small datasets only.
//
//  Notes:
//    - Data is serialized and deserialized using JSONEncoder/JSONDecoder.
//    - Encoding or decoding failures will result in no data being stored/loaded.
//

import Foundation

final class StorageManager {
    
    // The key used to store image data in `UserDefaults`
    private let key = "saved_images"
    
    // Loads the saved images from `UserDefaults`.
    // Returns: An array of `ImageItem`. Returns an empty array if no data is found or decoding fails.
    func load() -> [ImageItem] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let items = try? JSONDecoder().decode([ImageItem].self, from: data)
        else {
            return []
        }
        return items
    }
    
    // Saves an array of `ImageItem` to `UserDefaults`
    func save(_ items: [ImageItem]) {
        let data = try? JSONEncoder().encode(items)
        UserDefaults.standard.set(data, forKey: key)
    }
}
