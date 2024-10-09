//
//  DetailsViewModel.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import Foundation
import SwiftUI
import Combine

class DetailsViewModel: ObservableObject {
    @Published var creatorDetail: CreatorDetail?
    @Published var variantDetail: [Comic] = []
    @Published var comicDetail: Comic? = nil
    @Published var errorMessage: String = ""
    @Published var failure: Bool = false
    private let marvelService = MarvelService()
    private var cancellables = Set<AnyCancellable>()
    
    /// Fetches the details of a creator from the Marvel API using a secure URL.
    ///
    /// This function replaces the "http:" protocol in the resource URI with "https:" to ensure a secure connection,
    /// then calls the `marvelService` to fetch the creator's details. The result is handled asynchronously and the
    /// creator details are assigned to `creatorDetail`.
    ///
    /// - Parameters:
    ///   - resourceURI: The resource URI for the creator's details in the Marvel API.
    ///
    func fetchCreatorDetail(resourceURI: String) {
        let securePath = resourceURI.replacingOccurrences(of: "http:", with: "https:")
        marvelService.fetchCreatorDetails(from: securePath)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.failure = true
                    self.errorMessage = "Error fetching creator details"
                    print("Error fetching creator details: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] creator in
                DispatchQueue.main.async {
                    self?.creatorDetail = creator
                }
            })
            .store(in: &cancellables)
    }
    
    
    /// Fetches the details of the comic with the given ID.
    /// This function triggers a network request to the Marvel API via `MarvelService`
    /// to retrieve the details of the specified comic. It updates the published `comicDetail`
    /// property if successful, or sets the `errorMessage` and `failure` properties if it fails.
    ///
    /// - Parameter comicId: The ID of the comic to fetch details for.
    func fetchComicDetail(comicId: Int) {
        marvelService.fetchComicDetail(comicId: comicId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.failure = true
                case .finished:
                    break
                }
            }, receiveValue: { [self] comic in
                self.comicDetail = comic
                self.fetchAllVariants(variants: comic.variants ?? [], completion: { response in })
                self.fetchCreatorDetail(resourceURI: comic.creators?.collectionURI ?? "")
                print("-----------------\(comic)-------------------")
            })
            .store(in: &cancellables)  // Store the subscription to avoid memory leaks
    }
    
    
    /// Fetches the details of a comic variant from the Marvel API using a secure URL.
    ///
    /// This function replaces the "http:" protocol in the resource URI with "https:" to ensure a secure connection,
    /// then calls the `marvelService` to fetch the comic variant details. The result is handled asynchronously,
    /// and the details are passed to the completion handler.
    ///
    /// - Parameters:
    ///   - resourceURI: The resource URI for the comic variant details in the Marvel API.
    ///   - completion: A completion handler that provides the result of the fetch, either a `ComicVariant` on success or an `Error` on failure.
    ///
    func fetchVariantDetail(resourceURI: String, completion: @escaping (Result<ComicVariant, Error>) -> Void) {
        let securePath = resourceURI.replacingOccurrences(of: "http:", with: "https:")
        marvelService.fetchVariantDetails(from: securePath)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching variant details: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] variant in
                self?.variantDetail.append(contentsOf: variant)
            })
            .store(in: &cancellables)
    }
    
    /// Fetches all comic variants from an array of `ComicSummary` objects.
    ///
    /// This function iterates through a list of comic variants, fetches each variant's details asynchronously,
    /// and waits for all requests to complete before calling the completion handler with the fetched results.
    /// It uses a `DispatchGroup` to synchronize the completion of multiple network requests.
    ///
    /// - Parameters:
    ///   - variants: An array of `ComicSummary` objects, each containing a `resourceURI` for the variant.
    ///   - completion: A completion handler that returns an array of `ComicVariant` objects after all fetches are complete.
    ///
    func fetchAllVariants(variants: [ComicSummary], completion: @escaping ([ComicVariant]) -> Void) {
        let group = DispatchGroup()  // To check that all requests are completed
        var fetchedVariants = [ComicVariant]()
        
        for variant in variants {
            if let resourceURI = variant.resourceURI {
                group.enter()
                fetchVariantDetail(resourceURI: resourceURI) { result in
                    switch result {
                    case .success(let comicVariant):
                        fetchedVariants.append(comicVariant)
                    case .failure(let error):
                        print("Error fetching variant: \(error)")
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            completion(fetchedVariants)
        }
    }
}
