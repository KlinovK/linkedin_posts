//
//  Sendable.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 10/02/26.
//

import Foundation

// Not Sendable - mutable class

class UserSettings {
    var theme: String = "dark"
}

// Sendable - immutable struct

struct UserStructSendableCase: Sendable {
    let id: UUID
    let name: String
}

actor DataManagerSendableCase {
    // This works - User is Sendable
    func saveUser(_ user: UserStructSendableCase) async {
//        await database.save(user)
    }
    
    // Compiler error - UserSettings isn't Sendable!
    // func saveSettings(_ settings: UserSettings) async { }
}

//Practical use case:
//When fetching data from an API and updating your UI, @Sendable ensures the data models you pass to the main actor are safe:

@MainActor
class ViewModelSendableCase {
    func loadData() async {
//        let products = await fetchProducts() // Sendable type
//        self.products = products // Safe!
    }
}
