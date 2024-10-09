//
//  FavoritesView.swift
//  MarvelComics
//
//  Created by Gil casimiro on 08/10/24.
//

import SwiftUI
import CoreData

struct FavoritesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var comics: [ComicEntity] = []
    @State private var comicDelete: ComicEntity?
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var confirmDelete: Bool = false
    @State private var goToDetail: Bool = false
    @State private var id: Int = Int()
    var body: some View {
        VStack{
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(comics, id: \.self) { comic in
                        VStack {
                            if let url = comic.thumbnailURL {
                                AsyncImage(url: URL(string: url)) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 150)
                            }
                            Text(comic.title ?? "")
                                .font(.footnote)
                                .foregroundStyle(Color.black)
                                .lineLimit(2)
                        }
                        .padding()
                        .background(Color.init(hex: "#518cca")!)
                        .cornerRadius(8)
                        .onTapGesture{
                            goToDetail.toggle()
                            id = Int(comic.id)
                        }
                        .overlay(alignment: .topTrailing, content: {
                            Button(action: {
                                comicDelete = comic
                                confirmDelete.toggle()
                            }, label: {
                                Image(systemName: "minus.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.red)
                            })
                            .offset(x: 10, y: -10)
                        })
                        .frame(width: 150, height: 300)
                        .alert(isPresented: $confirmDelete, content: {
                            Alert(title: Text("You are about to delete this comic"), message: Text("Are you sure?"), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("Aceptar"), action: {
                                deleteComic(comicDelete ?? ComicEntity())
                                loadComicsFromCoreData()}))
                        })
                    }
                }
                NavigationLink(isActive: $goToDetail, destination:{ ComicDetailView(comicId: id)}, label: {EmptyView()})
                
            }
        }.padding(.horizontal)
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadComicsFromCoreData)
        .background(Color.init(hex: "#49a561")!)
        
    }
}

#Preview {
    FavoritesView()
}

extension FavoritesView {
    /// Loads all comics from Core Data and updates the `comics` array.
    ///
    /// This function fetches all stored `ComicEntity` records from Core Data, assigns them to the `comics` array,
    /// and prints the count of loaded comics. It also prints each loaded comic's title and ID for debugging purposes.
    ///
    func loadComicsFromCoreData() {
        let fetchRequest: NSFetchRequest<ComicEntity> = ComicEntity.fetchRequest()
        
        do {
            comics = try viewContext.fetch(fetchRequest)
            print("Comics loaded: \(comics.count)")
            for comic in comics {
                print("Comic loaded: \(comic.title ?? "No title"), ID: \(comic.id)")
            }
        } catch let error as NSError {
            print("Error loading comics: \(error), \(error.userInfo)")
        }
    }
    /// Deletes a comic from Core Data.
    ///
    /// This function removes the specified `ComicEntity` from Core Data and attempts to save the changes.
    /// If the deletion is successful, it prints a confirmation message. If an error occurs, it prints the error.
    ///
    /// - Parameters:
    ///   - comic: The `ComicEntity` to be deleted from Core Data.
    ///
    func deleteComic(_ comic: ComicEntity) {
        viewContext.delete(comic)
        do {
            try viewContext.save()
            print("Comic deleted successfully.")
        } catch {
            print("Error deleting the comic: \(error)")
        }
    }
}
