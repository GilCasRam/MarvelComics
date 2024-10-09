//
//  ComicsListModel.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import Foundation

// Respuesta de la API
struct MarvelResponse: Codable {
    let data: ComicDataWrapper
}

struct ComicDataWrapper: Codable {
    let results: [Comic]
}

// Estructura principal del cómic
struct Comic: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    var thumbnail: Thumbnail
    let variants: [ComicSummary]?
    let creators: CreatorList?
    
    struct Thumbnail: Codable {
        let path: String
        let `extension`: String

        var url: URL? {
            let securePath = path.replacingOccurrences(of: "http:", with: "https:")
            return URL(string: "\(securePath).\(`extension`)")
        }
    }
}

// Estructura para la lista de creadores
struct CreatorList: Codable {
    let available: Int?
    let collectionURI: String?
    let items: [CreatorSummary]?
}

// Información básica del creador
struct CreatorSummary: Codable {
// Usamos el `resourceURI` como identificador único, si está disponible
    var id: String { resourceURI ?? UUID().uuidString }
    let resourceURI: String?
    let name: String?
    let role: String?
}

// Estructura para las variantes del cómic
struct ComicSummary: Codable {
    var id: String { resourceURI ?? UUID().uuidString }
    let resourceURI: String?
    let name: String?
}
