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
    
    /// Saves a comic to Core Data.
    ///
    /// This method creates a new `ComicEntity` instance in the Core Data context,
    /// assigns the values from the `Comic` object, and attempts to save the context.
    ///
    /// - Parameters:
    ///   - comic: The `Comic` object containing the comic details to be saved.
    func saveComic(_ comic: Comic) {
        let context = container.viewContext  // Get the Core Data context.
        let entity = ComicEntity(context: context)
        
        entity.title = comic.title
        entity.comicDescription = comic.description
        entity.thumbnailURL = comic.thumbnail.url?.absoluteString
        entity.id = Int64(comic.id)
        // Save the context to persist the comic in Core Data.
        do {
            try context.save()
            print("Comic saved successfully.")
        } catch {
            print("Error saving the comic: \(error)")
        }
    }
    
    /// Loads all comics from Core Data and returns them as an array of `Comic` objects.
    ///
    /// This method fetches all `ComicEntity` records from Core Data, converts each entity to a `Comic` object,
    /// and returns the resulting list. If an error occurs during the fetch operation, it logs the error and returns an empty array.
    ///
    /// - Returns: An array of `Comic` objects retrieved from Core Data, or an empty array if an error occurs.
    func loadComics() -> [Comic] {
        let context = container.viewContext  // Get the Core Data context.
        let fetchRequest: NSFetchRequest<ComicEntity> = ComicEntity.fetchRequest()
        
        do {
            let comicEntities = try context.fetch(fetchRequest)
            return comicEntities.map { comicFromEntity($0) }
            
        } catch {
            print("Error loading comics: \(error)")
            return []
        }
    }
    
    /// Deletes a specific comic from Core Data.
    ///
    /// This method deletes the given `ComicEntity` from the Core Data context and attempts to save the changes.
    /// If the deletion is successful, a confirmation message is printed; otherwise, an error message is logged.
    ///
    /// - Parameters:
    ///   - comicEntity: The `ComicEntity` object to be deleted from Core Data.
    func deleteComic(_ comicEntity: ComicEntity) {
        let context = container.viewContext  // Get the Core Data context.
        context.delete(comicEntity)
        do {
            try context.save()  // Try to save the context after the deletion.
        } catch {
            print("Error deleting the comic: \(error)")
        }
    }
    
    /// Converts a `ComicEntity` from Core Data into a `Comic` object.
    ///
    /// This method extracts the necessary properties from the `ComicEntity`, constructs a `Comic` object,
    /// and handles missing or default values for properties like the thumbnail, variants, and creators.
    ///
    /// - Parameters:
    ///   - entity: The `ComicEntity` object retrieved from Core Data.
    /// - Returns: A `Comic` object created from the `ComicEntity` properties.
    func comicFromEntity(_ entity: ComicEntity) -> Comic {
        // Handle the URL for the thumbnail (if it exists).
        let thumbnailPath = entity.thumbnailURL ?? ""
        let thumbnailComponents = URL(string: thumbnailPath)
        
        // Create the `Thumbnail` object, handling both the path and extension.
        let thumbnail = Comic.Thumbnail(
            path: thumbnailComponents?.deletingLastPathComponent().absoluteString ?? "",
            extension: thumbnailComponents?.pathExtension ?? "jpg"
        )
        
        // Handle comic variants (optional, can be an empty list if not stored in the entity).
        let variants: [ComicSummary] = []
        
        // Handle creators (optional, can be default values if not stored in the entity).
        let creators: CreatorList = CreatorList(available: Int(), collectionURI: String(), items: [])
        
        // Return the fully constructed `Comic` object, using default values where necessary.
        return Comic(
            id: Int(entity.id),
            title: entity.title ?? "No title",
            description: entity.comicDescription ?? "No description",
            thumbnail: thumbnail,
            variants: variants,
            creators: creators
        )
    }}

