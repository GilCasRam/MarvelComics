//
//  ComicsListModel.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import Foundation

// API Response
struct MarvelResponse: Codable {
    let data: ComicDataWrapper
}

struct ComicDataWrapper: Codable {
    let results: [Comic]
}

// Main structure of the comic
struct Comic: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String?
    var thumbnail: Thumbnail
    let variants: [ComicSummary]?
    let creators: CreatorList?
    
    struct Thumbnail: Codable, Equatable {
        let path: String
        let `extension`: String
        
        var url: URL? {
            let securePath = path.replacingOccurrences(of: "http:", with: "https:")
            return URL(string: "\(securePath).\(`extension`)")
        }
    }
}

// Structure for the list of creators
struct CreatorList: Codable, Equatable{
    let available: Int?
    let collectionURI: String?
    let items: [CreatorSummary]?
}

// Basic information about the creator
struct CreatorSummary: Codable, Equatable {
    // We use the `resourceURI` as a unique identifier, if available.
    var id: String { resourceURI ?? UUID().uuidString }
    let resourceURI: String?
    let name: String?
    let role: String?
}

// Structure for comic variants
struct ComicSummary: Codable, Equatable {
    var id: String { resourceURI ?? UUID().uuidString }
    let resourceURI: String?
    let name: String?
}
