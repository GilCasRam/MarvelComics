//
//  ComicDetailView.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import CoreData
import SwiftUI

struct ComicDetailView: View {
    @StateObject private var viewModel = DetailsViewModel()
    @State private var isFavorite: Bool = false // Aquí podrías usar un mecanismo de persistencia para favoritos
    let comic: Comic
    
    // El contexto de CoreData desde el entorno
        @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Resumen del cómic
                Text(comic.title)
                    .font(.title)
                    .fontWeight(.bold)
                HStack{
                    // Portada del cómic
                    if let url = comic.thumbnail.url {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 250)
                        } placeholder: {
                            ProgressView()
                                .frame(height: 250)
                        }
                    }
                    if let description = comic.description {
                        Text(description)
                            .font(.body)
                            .padding(.bottom, 16)
                    } else {
                        Text("No description available.")
                            .italic()
                            .padding(.bottom, 16)
                    }
                }
                
                // Información del creador
                HStack {
                    if let creator = viewModel.creatorDetail {
                        if let creatorImageURL = creator.thumbnail.url {
                            AsyncImage(url: creatorImageURL) { image in
                                image.resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            }
                        }
                        VStack(alignment: .leading) {
                            Text("Created by:")
                                .font(.headline)
                            Text(creator.fullName)
                                .font(.subheadline)
                        }
                    } else {
                        ProgressView()
                    }
                }
                .padding(.bottom, 16)
                
                // Variantes de la portada
                Text("Variants")
                    .font(.headline)
                    .padding(.bottom, 8)
                if !viewModel.variantDetail.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.variantDetail, id: \.id) { variant in
                                VStack{
                                    if let variantUrl = variant.thumbnail.url {
                                        AsyncImage(url: variantUrl) { image in
                                            image.resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 100, height: 150)
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 100, height: 150)
                                        }
                                    }
                                    Text("\(variant.title)")
                                }
                            }
                        }
                    }
                    .padding(.bottom, 16)
                } else {
                    Text("No hay variates para mostrar")
                }
                
                // Botón para añadir o quitar de favoritos
                Button(action: {
                    saveComicToCoreData(comic: comic)
                    isFavorite.toggle()
                    // Aquí podrías añadir la lógica para persistir la lista de favoritos
                }) {
                    Text(isFavorite ? "Remove from favorites" : "Add to favorites")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isFavorite ? Color.red : Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Comic Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            viewModel.fetchCreatorDetail(resourceURI: comic.creators?.collectionURI ?? "")
            viewModel.fetchAllVariants(variants: comic.variants ?? [], completion: { response in })
            checkIfFavorite()
        }
    }
    // Método para guardar un cómic en CoreData
    func saveComicToCoreData(comic: Comic) {
            let newComic = ComicEntity(context: viewContext)
        newComic.title = comic.title
        newComic.comicDescription = comic.description
        newComic.thumbnailURL = comic.thumbnail.url?.absoluteString
        newComic.id = Int64(comic.id)
            
            do {
                try viewContext.save()
                print("Cómic guardado correctamente.")
            } catch {
                print("Error al guardar el cómic: \(error)")
            }
        }
    
    func checkIfFavorite() {
            let fetchRequest: NSFetchRequest<ComicEntity> = ComicEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", comic.id)
            
            do {
                let results = try viewContext.fetch(fetchRequest)
                isFavorite = !results.isEmpty  // Si hay resultados, significa que ya es favorito
            } catch {
                print("Error al verificar si el cómic es favorito: \(error)")
            }
        }

    // Eliminar el cómic de favoritos
       func removeFromFavorites() {
           let fetchRequest: NSFetchRequest<ComicEntity> = ComicEntity.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "id == %d", comic.id)
           
           do {
               let results = try viewContext.fetch(fetchRequest)
               for comic in results {
                   viewContext.delete(comic)
               }
               try viewContext.save()
               isFavorite = false  // Cambiar el estado a no favorito
               print("Cómic eliminado de favoritos")
           } catch {
               print("Error al eliminar de favoritos: \(error)")
           }
       }
}

//#Preview {
//    ComicDetailView(comic: Comic(id: 1, title: "DeadPool", description: "Es deadpool", thumbnail: Comic.Thumbnail(path: "", extension: "")))
//}
