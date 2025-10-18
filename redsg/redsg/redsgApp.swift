//
//  redsgApp.swift
//  redsg
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import SwiftUI

@main
struct redsgApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
