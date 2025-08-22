//
//  APIService.swift
//  LightspeedMobileTest
//
//  Created by Andrew So on 2025-08-22.
//

import Foundation

final class APIService {
    /// Fetches a list of images from the Picsum API.
    /// - Returns: An array of `ImageItem` decoded from JSON.
    /// - Throws: `URLError.badServerResponse` if the HTTP response is invalid,
    ///           or a decoding error if the data format is unexpected.
    final class APIService {
        func fetchImages() async throws -> [ImageItem] {
            let url = URL(string: "https://picsum.photos/v2/list")!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw URLError(.badServerResponse)
            }
            
            return try JSONDecoder().decode([ImageItem].self, from: data)
        }
    }
}
