//
//  router.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 21/02/26.
//

import SwiftUI

// 1. Define your routes
enum AppRoute: Hashable {
    case home
    case settings
}

// 2. Build your Router
@Observable
class Router {
    var path = NavigationPath()

    func push(_ route: AppRoute) { path.append(route) }
    func pop() { path.removeLast() }
    func popToRoot() { path.removeLast(path.count) }
}

// 3. Wire it up at the root
struct RootView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .home: HomeView()
                    case .settings:   SettingsView()
                    }
                }
        }
        .environment(router)
    }
}

// 4. Navigate from anywhere
struct HomeView: View {
    @Environment(Router.self) var router

    var body: some View {
        Button("Go to Detail") {
            router.push(.settings)
        }
    }
}


struct SettingsView: View {
    var body: some View {
        Text("Settings")
    }
}
