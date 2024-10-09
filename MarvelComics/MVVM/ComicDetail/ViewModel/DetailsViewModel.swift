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
    private let marvelService = MarvelService()
    private var cancellables = Set<AnyCancellable>()

    func fetchCreatorDetail(resourceURI: String) {
        let securePath = resourceURI.replacingOccurrences(of: "http:", with: "https:")
        marvelService.fetchCreatorDetails(from: securePath)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching creator details: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] creator in
                DispatchQueue.main.async {
                self?.creatorDetail = creator
                }
            })
            .store(in: &cancellables)
    }
    
    func fetchVariantDetail(resourceURI: String, completion: @escaping (Result<ComicVariant, Error>) -> Void) {
        let securePath = resourceURI.replacingOccurrences(of: "http:", with: "https:")
            marvelService.fetchVariantDetails(from: securePath)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error fetching variant details: \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] variant in                    self?.variantDetail.append(contentsOf: variant)
                })
                .store(in: &cancellables)
        }
    
    // Función para procesar todos los resourceURIs del array ComicSummary y devolver [ComicVariant]
    func fetchAllVariants(variants: [ComicSummary], completion: @escaping ([ComicVariant]) -> Void) {
        let group = DispatchGroup()  // Para controlar que todas las solicitudes terminen
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
