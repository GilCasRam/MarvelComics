//
//  Persistence.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import CoreData


struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MarvelComics")  // Asegúrate de usar el nombre correcto
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // Métodos para manejar los cómics en CoreData
    func saveComic(_ comic: Comic) {
        let context = container.viewContext
        let entity = ComicEntity(context: context)
        
        // Asignar valores
        entity.title = comic.title
        entity.comicDescription = comic.description
        entity.thumbnailURL = comic.thumbnail.url?.absoluteString
        entity.id = Int64(comic.id)  // Convertir Int a Int64 para CoreData
        
        // Guardar el contexto
        do {
            try context.save()
            print("Cómic guardado correctamente.")
        } catch {
            print("Error al guardar el cómic: \(error)")
        }
    }
    
    func loadComics() -> [Comic] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<ComicEntity> = ComicEntity.fetchRequest()
        
        do {
            let comicEntities = try context.fetch(fetchRequest)
            return comicEntities.map { comicFromEntity($0) }  // Convertimos ComicEntity a Comic
        } catch {
            print("Error al cargar los cómics: \(error)")
            return []
        }
    }
    
    func deleteComic(_ comicEntity: ComicEntity) {
        let context = container.viewContext
        context.delete(comicEntity)
        
        // Guardar los cambios
        do {
            try context.save()
            print("Cómic eliminado correctamente.")
        } catch {
            print("Error al eliminar el cómic: \(error)")
        }
    }
    
    // Método para convertir ComicEntity a Comic
    func comicFromEntity(_ entity: ComicEntity) -> Comic {
        // Manejo de la URL del thumbnail
        let thumbnailPath = entity.thumbnailURL ?? ""
        let thumbnailComponents = URL(string: thumbnailPath)
        
        // Creación del thumbnail
        let thumbnail = Comic.Thumbnail(
            path: thumbnailComponents?.deletingLastPathComponent().absoluteString ?? "",
            extension: thumbnailComponents?.pathExtension ?? "jpg"
        )
        
        // Manejo de variants y creators
        let variants: [ComicSummary] = []  // Si no tienes variantes en la entidad, puedes dejarlo como una lista vacía
        let creators: CreatorList = CreatorList(available: Int(), collectionURI: String(), items: [])  // Si no tienes creadores, lo mismo
        
        return Comic(
            id: Int(entity.id),
            title: entity.title ?? "Sin título",
            description: entity.comicDescription ?? "Sin descripción",
            thumbnail: thumbnail,
            variants: variants,  // Proporcionar la lista de variantes
            creators: creators   // Proporcionar la lista de creadores
        )
    }
}

