//
//  MainComicsListView.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import SwiftUI

struct MainComicsListView: View {
    @StateObject var viewModel = ComicsListViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        NavigationStack {
            VStack {
                // Campo de búsqueda
                SearchBarCustomV2(textToSearch: $viewModel.searchQuery)
                // Vista de carga
                if viewModel.isLoading {
                    VStack{
                        Spacer()
                        ProgressView("Loading Comics...")
                            .padding()
                        Spacer()
                    }
                } else {
                    // Lista de cómics en formato de cuadrícula
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.filteredComics, id: \.id) { comic in
                                NavigationLink(destination: ComicDetailView(comic: comic)) {
                                    ComicItemView(comic: comic)
                                }
                            }
                        }
                        .padding()
                    }
                }

                // Botón para favoritos
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
            .background(
                Color.init(hex: "#e23636")!
            )
            .onAppear {
                viewModel.fetchComics()
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

struct ComicItemView: View {
    let comic: Comic
    
    var body: some View {
        VStack {
            if let url = comic.thumbnail.url{
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 150)
            }
            Text(comic.title)
                .font(.footnote)
                .foregroundStyle(Color.black)
                .lineLimit(2)
        }
        .padding()
        .background(Color.init(hex: "#518cca")!)
        .cornerRadius(8)
    }
}
