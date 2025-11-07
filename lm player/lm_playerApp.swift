//
//  lm_playerApp.swift
//  lm player
//
//  Created by lokman şahin on 7.11.2025.
//

import SwiftUI
import CoreData

@main
struct lm_playerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
