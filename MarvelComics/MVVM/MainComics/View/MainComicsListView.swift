//
//  MainComicsListView.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import SwiftUI

struct MainComicsListView: View {
    @StateObject private var viewModel = ComicsListViewModel()
    var body: some View {
        NavigationStack {
            VStack {
                // Search field
                SearchBarCustom(textToSearch: $viewModel.searchQuery)
                // List of comics in grid format
                ScrollView {
                    LazyVGrid(columns: viewModel.columns, spacing: 16) {
                        ForEach(viewModel.filteredComics.indices, id: \.self) { index in
                            let comic = viewModel.comics[index]
                            NavigationLink(destination: ComicDetailView(comicId: comic.id)) {
                                ComicItemView(comic: comic)                                    
                                    .onAppear{
                                        if comic == viewModel.comics.last {
                                            viewModel.fetchMoreComics()
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                }
                // Favorites button
                NavigationLink(destination: {
                    FavoritesView()
                }) {
                    Text("Favorites")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Marvel Comics")
            .overlay(content: {
                // Loading view
                if viewModel.isLoading {
                    VStack{
                        Spacer()
                        ProgressView("Loading Comics...")
                            .padding()
                        Spacer()
                    }.frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.5))
                        
                }
            })
            .disabled(viewModel.isLoading)
            .background(
                Color.init(hex: "#e23636")!
            )
            .onAppear {
                viewModel.fetchComics(offset: 0, limit: 20)
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

#Preview {
    MainComicsListView()
}

