//
//  actor+viewModel.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 29/01/26.
//

import SwiftUI
import Combine

protocol NetworkServiceProtocol {
    func fetchData() async throws -> [String]
}

class UserNetworkService: NetworkServiceProtocol {
    func fetchData() async throws -> [String] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return ["Item 1", "Item 2", "Item 3"]
    }
}

@MainActor
final class UserViewModel: ObservableObject {
    @Published private(set) var items: [String] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    nonisolated private let networkService: NetworkServiceProtocol
    
    nonisolated init(networkService: NetworkServiceProtocol = UserNetworkService()) {
        self.networkService = networkService
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let fetchedItems = try await networkService.fetchData()
            self.items = fetchedItems
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

struct UserContentView: View {
    @StateObject private var viewModel = UserViewModel()
    
    var body: some View {
        ZStack {
            List(viewModel.items, id: \.self) { item in
                Text(item)
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}
