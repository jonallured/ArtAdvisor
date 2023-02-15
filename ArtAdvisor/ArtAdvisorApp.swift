//
//  ArtAdvisorApp.swift
//  ArtAdvisor
//
//  Created by Jonathan Allured on 2/9/23.
//

import SwiftUI

@main
struct ArtAdvisorApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(currentUser: User.makeFake())
                    .tabItem {
                        Label("Content", systemImage: "list.dash")
                    }
                SyncEventsView()
                    .tabItem {
                        Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                    }
            }
        }
    }
}
