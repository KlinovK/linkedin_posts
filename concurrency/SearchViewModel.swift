//
//  SearchViewModel.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 10/01/26.
//

import SwiftUI

@MainActor
class SearchViewModel {

    private var searchTask: Task<Void, Never>?
    
    func search(query: String) {
        searchTask?.cancel()  // Cancel previous search
        
        searchTask = Task {
            // Debounce: wait 300ms before searching
            try? await Task.sleep(nanoseconds: 300_000_000)
            if Task.isCancelled { return }
            
            let results = await performSearch(query)
            await updateUI(with: results)
        }
    }
    
    // Implement the actual search logic
    private func performSearch(_ query: String) async -> [String] {
        
        // Simulate network request or database query
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Example: Filter mock data
        let mockData = ["Apple", "Apricot", "Banana", "Cherry", "Date"]
        return mockData.filter { $0.localizedCaseInsensitiveContains(query) }
    }
    
    // Update the UI with results
    private func updateUI(with results: [String]) async {
    }
    
    // Clean up when done
    func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
    }
}
