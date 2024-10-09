//
//  ComicsListViewModel.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import Foundation
import Combine

class ComicsListViewModel: ObservableObject {
    @Published var comics: [Comic] = []
    @Published var filteredComics: [Comic] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    
    private let marvelService: MarvelService
    private var cancellables = Set<AnyCancellable>()
    
    init(marvelService: MarvelService = MarvelService()) {
        self.marvelService = marvelService
        setupSearchListener()
        fetchComics()
    }
    
    func fetchComics() {
        isLoading = true
        marvelService.fetchComics()
            .sink(receiveCompletion: { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    case .finished:
                        break
                    }
                }
            }, receiveValue: { [weak self] comics in
                DispatchQueue.main.async {
                    self?.comics = comics
                    self?.filteredComics = comics
                }
            })
            .store(in: &cancellables)
    }
    
    // Método para buscar cómics en base a la búsqueda en tiempo real
    private func setupSearchListener() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) // Espera 300ms antes de buscar
            .removeDuplicates() // Evita búsquedas repetitivas si el valor no cambia
            .sink { [weak self] query in
                self?.searchComics()
            }
            .store(in: &cancellables)
    }

    // Método para realizar la búsqueda en la lista local o llamar a la API
    func searchComics() {
        if searchQuery.isEmpty {
            filteredComics = comics
        } else {
            filteredComics = comics.filter { $0.title.lowercased().contains(searchQuery.lowercased()) }
        }
    }
}


