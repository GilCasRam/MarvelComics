//
//  ComicDetailModel.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import Foundation

// Respuesta de la API para obtener los detalles de un creador
struct CreatorResponse: Codable {
    let data: CreatorDataWrapper
}

struct CreatorDataWrapper: Codable {
    let results: [CreatorDetail]
}

// Detalles completos del creador, incluyendo la imagen
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

// Estructura para almacenar el resultado con name y thumbnail URL
struct ComicVariant {
    let name: String?
    let thumbnailURL: String?
}
