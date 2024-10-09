//
//  ComicsListViewModel.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import Foundation
import Combine
import SwiftUI

class ComicsListViewModel: ObservableObject {
    @Published var comics: [Comic] = []
    @Published var filteredComics: [Comic] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    private let marvelService: MarvelService
    private var cancellables = Set<AnyCancellable>()
    private var currentOffset: Int = 0
    private let limit = 20
    private var totalComics: Int = 0
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    init(marvelService: MarvelService = MarvelService()) {
        self.marvelService = marvelService
        setupSearchListener()
    }
    
    // Función para cargar más cómics cuando llegamos al final de la lista
    func fetchMoreComics() {
        fetchComics(offset: currentOffset, limit: limit)
    }
    
    // Resetear los datos al cargar por primera vez
    func fetchInitialComics() {
        currentOffset = 0
        comics.removeAll()  // Limpia la lista de cómics si se reinicia
        fetchComics(offset: currentOffset, limit: limit)
    }
    
    
    /// Fetches comics from the Marvel service and updates the view state.
    ///
    /// This function triggers the comic fetching process, updates the `isLoading` flag, handles any errors,
    /// and populates the list of comics and filtered comics. It uses Combine to manage asynchronous operations and
    /// stores the cancellables to prevent memory leaks.
    ///
    /// - Note: This function uses the `marvelService` to fetch comics and handles the result or error using Combine's `sink`.
    ///
    func fetchComics(offset: Int , limit: Int) {
        isLoading = true
        marvelService.fetchComics(offset: offset, limit: limit)
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
            }, receiveValue: { [weak self] newComics in
                DispatchQueue.main.async {
                    self?.comics.append(contentsOf: newComics)
                    self?.filteredComics = self?.comics ?? []
                    // Actualizar el total de cómics disponibles (solo en la primera carga)
                    if self?.totalComics == 0 {
                        self?.totalComics = newComics.count
                    }
                    // Incrementar el offset para la próxima página
                    if newComics.count > 0 {
                        self?.currentOffset += newComics.count
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    /// Sets up a listener for the search query to trigger comic search with a delay.
    ///
    /// This function listens for changes to the `searchQuery` property, debounces the input to prevent
    /// excessive searches, and triggers the comic search. It uses Combine to handle the debounce and sink operations.
    ///
    /// - Note: The search is triggered 300ms after the user stops typing and only if the query changes from the previous value.
    ///
    private func setupSearchListener() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) // Espera 300ms antes de buscar
            .removeDuplicates() // Evita búsquedas repetitivas si el valor no cambia
            .sink { [weak self] query in
                self?.searchComics()
            }
            .store(in: &cancellables)
    }
    
    /// Filters the list of comics based on the search query.
    ///
    /// This function checks if the search query is empty. If it is, it resets the `filteredComics` list to show all comics.
    /// Otherwise, it filters the comics by checking if the comic's title contains the search query (case-insensitive).
    ///
    func searchComics() {
        if searchQuery.isEmpty {
            filteredComics = comics
        } else {
            filteredComics = comics.filter { $0.title.lowercased().contains(searchQuery.lowercased()) }
        }
    }
}


