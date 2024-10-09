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
    var body: some View {
        List {
            ForEach(comics, id: \.self) { comic in
                HStack {
                    Text(comic.title ?? "Sin título")
                    Spacer()
                    Button("Eliminar") {
                        deleteComic(comic)
                        loadComicsFromCoreData()
                    }
                    .foregroundColor(.red)
                }
            }
        }.onAppear(perform: loadComicsFromCoreData)

    }
    // Método para cargar todos los cómics manualmente desde CoreData usando NSFetchRequest
    func loadComicsFromCoreData() {
        let fetchRequest: NSFetchRequest<ComicEntity> = ComicEntity.fetchRequest()

        do {
            comics = try viewContext.fetch(fetchRequest)
            print("Cómics cargados: \(comics.count)")
            for comic in comics {
                print("Cómic cargado: \(comic.title ?? "Sin título"), ID: \(comic.id)")
            }
        } catch let error as NSError {
            print("Error al cargar los cómics: \(error), \(error.userInfo)")
        }
    }
    // Método para eliminar un cómic
        func deleteComic(_ comic: ComicEntity) {
            viewContext.delete(comic)
            
            do {
                try viewContext.save()
                print("Cómic eliminado correctamente.")
            } catch {
                print("Error al eliminar el cómic: \(error)")
            }
        }

}

#Preview {
    FavoritesView()
}
