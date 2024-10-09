//
//  ComicDetailView.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import CoreData
import SwiftUI

struct ComicDetailView: View {
    // The CoreData context from the environment
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = DetailsViewModel()
    @State private var isFavorite: Bool = false
    let comicId: Int
    var body: some View {
        VStack{
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Summary of the comic
                    Text(viewModel.comicDetail?.title ?? "N/A")
                        .font(.title)
                        .fontWeight(.bold)
                    HStack{
                        // Comic book cover
                        if let url = viewModel.comicDetail?.thumbnail.url {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 250)
                            } placeholder: {
                                ProgressView()
                                    .frame(height: 250)
                            }
                        }
                        if let description = viewModel.comicDetail?.description {
                            if description != "" {
                                Text(description)
                                    .font(.body)
                                    .padding(.bottom, 16)
                            } else {
                                Text("No description available.")
                                    .italic()
                                    .padding(.bottom, 16)
                            }
                        }
                    }
                    // Creator's information
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
                            if viewModel.errorMessage != "" {
                                VStack(alignment: .leading) {
                                    Text("Created by:")
                                        .font(.headline)
                                    Text("Unkwon")
                                        .font(.subheadline)
                                }
                            } else {
                                ProgressView()
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    // Variants of the cover
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
                                            .lineLimit(2)
                                    }.frame(width: 150, height: 220)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .foregroundStyle( Color.init(hex: "#575757")!)
                                                .frame(width: 150, height: 220)
                                        )
                                }
                            }.padding()
                        }
                        .padding(.bottom, 16)
                    } else {
                        Text("No variates to display")
                    }
                }
                .padding()
            }
            // Button to add or remove from favorites
            Button(action: {
                if isFavorite {
                    removeFromFavorites()
                    isFavorite = false
                } else {
                    if let comicDetail = viewModel.comicDetail {
                        saveComicToCoreData(comic: comicDetail)
                        isFavorite = true
                    }
                }
                
                // Here you could add the logic to persist the list of favorites
            }) {
                Text(isFavorite ? "Remove from favorites" : "Add to favorites")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isFavorite ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Comic Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.init(hex: "#7c5fab")!)
        .onAppear{
            viewModel.fetchComicDetail(comicId: comicId)
            checkIfFavorite()
        }
        .alert(isPresented: $viewModel.failure, content: {
            Alert(title: Text("\(viewModel.errorMessage)"))
            })
    }
}

extension ComicDetailView {
    /// Saves a `Comic` object to Core Data.
    ///
    /// This function creates a new `ComicEntity` (Core Data entity) and populates it with the relevant
    /// data from the `Comic` object, including the title, description, thumbnail URL, and ID. It then attempts to save the context.
    ///
    /// - Parameters:
    ///   - comic: The `Comic` object to be saved into Core Data.
    ///
    func saveComicToCoreData(comic: Comic) {
        let newComic = ComicEntity(context: viewContext)
        newComic.title = comic.title
        newComic.comicDescription = comic.description
        newComic.thumbnailURL = comic.thumbnail.url?.absoluteString
        newComic.id = Int64(comic.id)
        
        do {
            try viewContext.save()
            print("Comic book stored correctly.")
        } catch {
            print("Error saving the comic: \(error)")
        }
    }
    
    /// Checks if the current comic is marked as a favorite in Core Data.
    ///
    /// This function creates a fetch request to search for the comic in the `ComicEntity` (Core Data) by its ID.
    /// If a result is found, the comic is already marked as a favorite, and the `isFavorite` flag is set accordingly.
    ///
    /// - Note: The comic is considered a favorite if it exists in Core Data.
    ///
    func checkIfFavorite() {
        let fetchRequest: NSFetchRequest<ComicEntity> = ComicEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", comicId)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            isFavorite = !results.isEmpty  // If there are results, it means that he is already a favorite
        } catch {
            print("Error when checking if the comic is a favorite: \(error)")
        }
    }
    
    /// Removes the current comic from the favorites stored in Core Data.
    ///
    /// This function searches for the comic in the `ComicEntity` (Core Data) by its ID. If found, it deletes the
    /// comic from Core Data and updates the `isFavorite` status to `false`.
    ///
    func removeFromFavorites() {
        let fetchRequest: NSFetchRequest<ComicEntity> = ComicEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", comicId)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            for comic in results {
                viewContext.delete(comic)
            }
            try viewContext.save()
            isFavorite = false  // Change status to not favorite
            print("Comic removed from favorites")
        } catch {
            print("Error deleting from favorites: \(error)")
        }
    }
}
