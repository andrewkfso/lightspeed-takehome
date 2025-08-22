//
//  ImageItem.swift
//  LightspeedMobileTest
//
//  Created by Andrew So on 2025-08-22.
//

import Foundation

struct ImageItem: Codable, Identifiable, Equatable {
    let id: String
    let author: String
    let download_url: String
}
