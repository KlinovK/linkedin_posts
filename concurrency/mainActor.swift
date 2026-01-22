//
//  mainActor.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 21/01/26.
//

import Foundation
import UIKit
import SwiftUI
import Combine

var dataToReceive = [] as [String]

nonisolated func heavyDataProcessing() -> [String] {
    return []
}

class NetworkService {
    func fetchData() async -> [String] {
        return []
    }
}

func fetchDataInBackground() async -> [String] {
    return try! await withCheckedThrowingContinuation { continuation in
        DispatchQueue.global().async {
            let data = heavyDataProcessing()
            continuation.resume(returning: data)
        }
    }
}

// Tip #1: Use nonisolated for non-UI logic

@MainActor
class HeavyDataProcessingViewModel {
    func updateUI() {
        // Runs on main thread
    }
    
    nonisolated func processData() -> [String] {
        return heavyDataProcessing()  // ✅ Works now
    }
}

// Tip #2: SwiftUI views are already @MainActor

@MainActor
class ContentViewModel: ObservableObject {
    @Published var items: [Item] = []
}

// Tip #3: Calling non-MainActor code requires 'await'

@MainActor
class NonMainActorViewModel {
    
    let networkService = NetworkService()
    var items: [String] = []
    
    func loadData() async {
        // This switches off main thread, then back
        let data = await networkService.fetchData()
        // Back on main thread for UI update
        self.items = data
    }
}

// Tip #4: Use MainActor.run for one-off updates

func test() async {
    Task {
        let data = await fetchDataInBackground()
        await MainActor.run {
            dataToReceive = data
        }
    }
}

// Tip #5: Avoid blocking the main thread

@MainActor
class ProcessAnddisplayViewModel {
    
    var data: [String] = []
    
    func processAndDisplay() async {
        // Heavy work on background
        let result = await Task.detached {
            heavyDataProcessing()
        }.value
        
        // UI update on main (automatic)
        self.data = result
    }
}

