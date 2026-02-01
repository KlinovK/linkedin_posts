//
//  isolatedvsnonisolated.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 30/01/26.
//

import Foundation

actor DataManagerExample {
    // ISOLATED METHOD (default for actors)
    // - Runs one at a time to prevent data races
    // - Must be called with 'await' keyword
    // - Protected by the actor's synchronization
    func saveData() async {
        // Safe, sequential access
        // Only one caller can execute this at a time
        // Perfect for modifying shared state
    }
    
    // NONISOLATED PROPERTY
    // - Escapes actor isolation
    // - Can be accessed synchronously (no 'await')
    // - Safe because it doesn't access mutable actor state
    // - Returns immediately without waiting in queue
    nonisolated var managerID: String {
        return "Constant"  // Constant value, no race condition possible
    }
}

// USAGE EXAMPLES:
// await manager.saveData()     // ← Must use 'await' (isolated)
// let id = manager.managerID   // ← No 'await' needed (nonisolated)



