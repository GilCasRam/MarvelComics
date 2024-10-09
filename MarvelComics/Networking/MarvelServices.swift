//
//  MarvelServices.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import Foundation
import Combine
import CryptoKit
class MarvelService {
    private let publicKey = "33b6f701db0cd1e741b284982657bf71"
    private let baseUrl = "https://gateway.marvel.com/v1/public/comics"
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()

    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // Método para obtener cómics con Combine
    func fetchComics() -> AnyPublisher<[Comic], Error> {
        guard let url = makeURL() else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MarvelResponse.self, decoder: JSONDecoder())
            .map { $0.data.results }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // Método para construir la URL
    private func makeURL() -> URL? {
        var components = URLComponents(string: baseUrl)
        let timestamp = "\(Date().timeIntervalSince1970)"
        let hash = generateMD5Hash(timestamp: timestamp)

        components?.queryItems = [
            URLQueryItem(name: "apikey", value: publicKey),
            URLQueryItem(name: "ts", value: timestamp),
            URLQueryItem(name: "hash", value: hash)
        ]

        return components?.url
    }
    // Método para obtener los detalles del creador
    func fetchCreatorDetails(from resourceURI: String) -> AnyPublisher<CreatorDetail, Error> {
          guard let url = makeDetailsURL(from: resourceURI) else {
              return Fail(error: URLError(.badURL))
                  .eraseToAnyPublisher()
          }

          return session.dataTaskPublisher(for: url)
              .map(\.data)
//              .decode(type: CreatorResponse.self, decoder: JSONDecoder())
              .tryMap { data in
                         let decodedResponse = try JSONDecoder().decode(CreatorResponse.self, from: data)

                         // Verificar si el array de resultados no está vacío
                         guard let creatorDetail = decodedResponse.data.results.first else {
                             throw URLError(.badServerResponse)
                         }

                         return creatorDetail
                     }
              .eraseToAnyPublisher()
      }

      // Método para construir la URL a partir del resourceURI
      private func makeDetailsURL(from resourceURI: String) -> URL? {
          var components = URLComponents(string: resourceURI)
          let timestamp = "\(Date().timeIntervalSince1970)"
          let hash = generateMD5Hash(timestamp: timestamp)

          components?.queryItems = [
              URLQueryItem(name: "apikey", value: publicKey),
              URLQueryItem(name: "ts", value: timestamp),
              URLQueryItem(name: "hash", value: hash)
          ]

          return components?.url
      }
    // Método para obtener los detalles de una variante
    func fetchVariantDetails(from resourceURI: String) -> AnyPublisher<[Comic], Error> {
           guard let url = makeDetailsURL(from: resourceURI) else {
               return Fail(error: URLError(.badURL))
                   .eraseToAnyPublisher()
           }

           return session.dataTaskPublisher(for: url)
               .map(\.data)
               .decode(type: MarvelResponse.self, decoder: JSONDecoder())
               .map { $0.data.results }  // Obtiene el primer resultado
               .eraseToAnyPublisher()
       }


    // Generar el hash para la autenticación
    private func generateMD5Hash(timestamp: String) -> String {
        let privateKey = "de267556db99df19cd64b086b9f3e9f956d715f8"
        let data = "\(timestamp)\(privateKey)\(publicKey)".data(using: .utf8)!
        return Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
    }
}
