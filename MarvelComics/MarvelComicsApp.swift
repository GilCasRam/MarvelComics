//
//  MarvelComicsApp.swift
//  MarvelComics
//
//  Created by Gil casimiro on 07/10/24.
//

import SwiftUI

@main
struct MarvelComicsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainComicsListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
