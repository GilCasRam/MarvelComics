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
    
    /// Fetches a list of comics from the Marvel API.
    ///
    /// This function constructs a URL, makes a network request, and processes the response to fetch a list of `Comic` objects.
    /// It uses Combine's `AnyPublisher` to handle asynchronous data fetching, parsing, and potential errors.
    ///
    /// - Returns: A publisher that outputs an array of `Comic` or an `Error` if the fetch fails.
    ///
    func fetchComics(offset: Int = 0, limit: Int = 20) -> AnyPublisher<[Comic], Error> {
        guard let url = makeURL(offset: offset, limit: limit) else {
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
    
    /// Creates the full URL for fetching data from the Marvel API.
    ///
    /// This function constructs a URL with the necessary query parameters, including the API key, timestamp,
    /// and hash required for authentication with the Marvel API.
    ///
    /// - Returns: A `URL` object if the components are successfully constructed, or `nil` if the URL is invalid.
    ///
    private func makeURL(offset: Int , limit: Int) -> URL? {
        var components = URLComponents(string: baseUrl)
        let timestamp = "\(Date().timeIntervalSince1970)"
        let hash = generateMD5Hash(timestamp: timestamp)
        components?.queryItems = [
            URLQueryItem(name: "apikey", value: publicKey),
            URLQueryItem(name: "ts", value: timestamp),
            URLQueryItem(name: "hash", value: hash),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)")  
        ]
        
        return components?.url
    }
    
    /// Fetches the details of a creator from the Marvel API using the provided resource URI.
    ///
    /// This function takes a resource URI that points to a specific creator's details, constructs a URL,
    /// performs a network request, and decodes the response into a `CreatorDetail` object.
    /// If the URL creation or network request fails, it returns an error.
    ///
    /// - Parameters:
    ///   - resourceURI: The URI pointing to the creator's details in the Marvel API.
    /// - Returns: A publisher that emits the `CreatorDetail` or an `Error` if the fetch fails.
    ///
    func fetchCreatorDetails(from resourceURI: String) -> AnyPublisher<CreatorDetail, Error> {
        guard let url = makeDetailsURL(from: resourceURI) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data in
                let decodedResponse = try JSONDecoder().decode(CreatorResponse.self, from: data)
                
                // Verify if the array is empty
                guard let creatorDetail = decodedResponse.data.results.first else {
                    throw URLError(.badServerResponse)
                }
                
                return creatorDetail
            }
            .eraseToAnyPublisher()
    }
    
    /// Creates a URL for fetching details from the Marvel API using a provided resource URI.
    ///
    /// This function takes a resource URI (such as a creator's detail URI) and appends the necessary query parameters
    /// for authentication with the Marvel API, including the API key, timestamp, and MD5 hash.
    ///
    /// - Parameters:
    ///   - resourceURI: The URI that points to the specific details (e.g., creator details).
    /// - Returns: A `URL` object with the required query parameters, or `nil` if the URL could not be constructed.
    ///
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
    
    /// Fetches the variant details of a comic from the Marvel API using the provided resource URI.
    ///
    /// This function takes a resource URI, constructs a URL, makes a network request, and decodes the response into
    /// an array of `Comic` objects (variants). It uses Combine's `AnyPublisher` to handle asynchronous data fetching and error handling.
    ///
    /// - Parameters:
    ///   - resourceURI: The URI pointing to the comic variant details in the Marvel API.
    /// - Returns: A publisher that emits an array of `Comic` objects or an `Error` if the fetch fails.
    ///
    func fetchVariantDetails(from resourceURI: String) -> AnyPublisher<[Comic], Error> {
        guard let url = makeDetailsURL(from: resourceURI) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MarvelResponse.self, decoder: JSONDecoder())
            .map { $0.data.results }  // Get the first result
            .eraseToAnyPublisher()
    }
    
    
    /// Generates an MD5 hash for Marvel API authentication.
    ///
    /// This function generates an MD5 hash using the timestamp, the private API key, and the public API key.
    /// The Marvel API requires this hash for authenticated requests.
    ///
    /// - Parameters:
    ///   - timestamp: The timestamp string used in the authentication hash.
    /// - Returns: A string representing the MD5 hash, which is used for Marvel API authentication.
    ///
    private func generateMD5Hash(timestamp: String) -> String {
        let privateKey = "de267556db99df19cd64b086b9f3e9f956d715f8"
        let data = "\(timestamp)\(privateKey)\(publicKey)".data(using: .utf8)!
        return Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
    }
}
