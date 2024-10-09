//
//  ComicDetailModel.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import Foundation

// API response to obtain creator details
struct CreatorResponse: Codable {
    let data: CreatorDataWrapper
}

struct CreatorDataWrapper: Codable {
    let results: [CreatorDetail]
}

// Full details of the creator, including image
struct CreatorDetail: Codable, Identifiable {
    let id: Int
    let fullName: String
    let thumbnail: Thumbnail

    struct Thumbnail: Codable {
        let path: String
        let `extension`: String

        var url: URL? {
            let securePath = path.replacingOccurrences(of: "http:", with: "https:")
            return URL(string: "\(securePath).\(`extension`)")
        }
    }
}

// Structure to store the result with name and thumbnail URL
struct ComicVariant {
    let name: String?
    let thumbnailURL: String?
}
