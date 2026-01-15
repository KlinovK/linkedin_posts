//
//  TaskCancelation.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 15/01/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Models

struct Item: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
}

struct Result: Identifiable {
    let id = UUID()
    let value: String
}

// MARK: - 1. Search View with Automatic Cancellation

struct SearchView: View {
    @State private var searchQuery = ""
    @State private var results: [Item] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            List(results) { item in
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                    Text(item.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .searchable(text: $searchQuery)
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
            .task(id: searchQuery) {
                // Previous task auto-cancelled when query changes!
                await performSearch(query: searchQuery)
            }
            .navigationTitle("Search Items")
        }
    }
    
    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            results = []
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Simulate network delay
            try await Task.sleep(for: .milliseconds(500))
            
            // Check if cancelled after delay
            try Task.checkCancellation()
            
            // Simulate API call
            results = try await searchAPI(query: query)
        } catch is CancellationError {
            // Task was cancelled, don't update results
            print("Search cancelled for query: \(query)")
        } catch {
            print("Search error: \(error)")
        }
    }
    
    private func searchAPI(query: String) async throws -> [Item] {
        // Simulate API response
        return [
            Item(id: "1", name: "\(query) Result 1", description: "Description for result 1"),
            Item(id: "2", name: "\(query) Result 2", description: "Description for result 2"),
            Item(id: "3", name: "\(query) Result 3", description: "Description for result 3")
        ]
    }
}

// MARK: - 2. View Model with Task Management

enum ViewState: Equatable {
    case idle
    case loading
    case item(Item)
    case error(String)
    
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case let (.item(l), .item(r)):
            return l.id == r.id
        case let (.error(l), .error(r)):
            return l == r
        default:
            return false
        }
    }
}

class FoodViewModel: ObservableObject {
    @Published private(set) var state: ViewState = .idle
    private var cancellable: AnyCancellable?
    
    func loadItem(id: String) {
        // Cancel previous task automatically when new one starts
        cancellable = Task { @MainActor in
            do {
                state = .loading
                let item = try await fetch(id: id)
                state = .item(item)
            } catch is CancellationError {
                // Don't show error for cancellation
                state = .idle
            } catch {
                state = .error(error.localizedDescription)
            }
        }.eraseToAnyCancellable()
    }
    
    private func fetch(id: String) async throws -> Item {
        // Simulate network delay
        try await Task.sleep(for: .seconds(2))
        
        // Check if cancelled
        try Task.checkCancellation()
        
        // Simulate API response
        return Item(
            id: id,
            name: "Food Item \(id)",
            description: "Delicious food item with ID \(id)"
        )
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

struct FoodView: View {
    @StateObject private var viewModel = FoodViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            switch viewModel.state {
            case .idle:
                Text("Select an item to load")
            case .loading:
                ProgressView()
            case .item(let item):
                VStack {
                    Text(item.name)
                        .font(.title)
                    Text(item.description)
                        .foregroundColor(.secondary)
                }
            case .error(let message):
                Text("Error: \(message)")
                    .foregroundColor(.red)
            }
            
            HStack(spacing: 20) {
                Button("Load Item 1") {
                    viewModel.loadItem(id: "1")
                }
                Button("Load Item 2") {
                    viewModel.loadItem(id: "2")
                }
                Button("Cancel") {
                    viewModel.cancel()
                }
            }
        }
        .padding()
    }
}

// MARK: - 3. Long-Running Operations with Cancellation Checks

class DataProcessor {
    func processLargeDataset() async throws -> [Result] {
        print("Starting data fetch...")
        let data = try await fetchData()
        
        // Check if cancelled after network call
        try Task.checkCancellation()
        print("Data fetched, starting processing...")
        
        let processed = try expensiveProcessing(data)
        
        // Check again after expensive operation
        try Task.checkCancellation()
        print("Processing complete, finalizing...")
        
        return finalizeResults(processed)
    }
    
    private func fetchData() async throws -> [String] {
        // Simulate network call
        try await Task.sleep(for: .seconds(1))
        return Array(repeating: "data", count: 1000)
    }
    
    private func expensiveProcessing(_ data: [String]) throws -> [String] {
        var results: [String] = []
        
        for (index, item) in data.enumerated() {
            // Check cancellation periodically in loops
            if index % 100 == 0 {
                try Task.checkCancellation()
            }
            
            // Simulate expensive work
            results.append(item.uppercased())
        }
        
        return results
    }
    
    private func finalizeResults(_ processed: [String]) -> [Result] {
        return processed.prefix(10).map { Result(value: $0) }
    }
}

struct ProcessingView: View {
    @State private var results: [Result] = []
    @State private var isProcessing = false
    @State private var currentTask: Task<Void, Never>?
    
    var body: some View {
        VStack(spacing: 20) {
            if isProcessing {
                ProgressView("Processing...")
            } else if results.isEmpty {
                Text("Tap 'Start Processing' to begin")
            } else {
                List(results) { result in
                    Text(result.value)
                }
            }
            
            HStack(spacing: 20) {
                Button("Start Processing") {
                    startProcessing()
                }
                .disabled(isProcessing)
                
                Button("Cancel") {
                    currentTask?.cancel()
                }
                .disabled(!isProcessing)
            }
        }
        .padding()
    }
    
    private func startProcessing() {
        currentTask = Task {
            isProcessing = true
            defer { isProcessing = false }
            
            let processor = DataProcessor()
            do {
                results = try await processor.processLargeDataset()
                print("Processing completed successfully")
            } catch is CancellationError {
                print("Processing was cancelled")
                results = []
            } catch {
                print("Processing error: \(error)")
            }
        }
    }
}

// MARK: - 4. Task Groups with Cancellation

struct ImageDownloader {
    func downloadFirstAvailableImage(from urls: [URL]) async throws -> UIImage? {
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            // Start downloading all images concurrently
            for url in urls {
                group.addTask {
                    try await self.downloadImage(from: url)
                }
            }
            
            do {
                // Wait for first successful download
                while let image = try await group.next() {
                    if let image = image {
                        // Got an image, cancel remaining downloads
                        group.cancelAll()
                        return image
                    }
                }
                return nil
            } catch {
                // Error occurred, cancel all remaining tasks
                group.cancelAll()
                throw error
            }
        }
    }
    
    func downloadAllImages(from urls: [URL]) async -> [UIImage] {
        await withTaskGroup(of: UIImage?.self) { group in
            for url in urls {
                group.addTask {
                    try? await self.downloadImage(from: url)
                }
            }
            
            var images: [UIImage] = []
            for await image in group {
                if let image = image {
                    images.append(image)
                }
                
                // Optional: cancel remaining if we have enough
                if images.count >= 3 {
                    group.cancelAll()
                    break
                }
            }
            return images
        }
    }
    
    private func downloadImage(from url: URL) async throws -> UIImage? {
        // Check if already cancelled
        try Task.checkCancellation()
        
        // Simulate download delay
        try await Task.sleep(for: .milliseconds(Int.random(in: 500...2000)))
        
        // Check again after delay
        try Task.checkCancellation()
        
        // Simulate image creation
        return UIImage(systemName: "photo")
    }
}

struct ImageDownloadView: View {
    @State private var downloadedImage: UIImage?
    @State private var isDownloading = false
    @State private var currentTask: Task<Void, Never>?
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = downloadedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Text("Downloaded successfully!")
            } else if isDownloading {
                ProgressView("Downloading first available image...")
            } else {
                Text("Tap to download")
            }
            
            HStack(spacing: 20) {
                Button("Download First") {
                    downloadFirst()
                }
                .disabled(isDownloading)
                
                Button("Cancel") {
                    currentTask?.cancel()
                }
                .disabled(!isDownloading)
            }
        }
        .padding()
    }
    
    private func downloadFirst() {
        currentTask = Task {
            isDownloading = true
            defer { isDownloading = false }
            
            let urls = (1...5).map { URL(string: "https://example.com/image\($0).jpg")! }
            let downloader = ImageDownloader()
            
            do {
                downloadedImage = try await downloader.downloadFirstAvailableImage(from: urls)
            } catch is CancellationError {
                print("Download cancelled")
            } catch {
                print("Download error: \(error)")
            }
        }
    }
}

// MARK: - Main Demo App

struct TaskCancellationDemoApp: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            FoodView()
                .tabItem {
                    Label("Food", systemImage: "fork.knife")
                }
            
            ProcessingView()
                .tabItem {
                    Label("Processing", systemImage: "gearshape")
                }
            
            ImageDownloadView()
                .tabItem {
                    Label("Download", systemImage: "arrow.down.circle")
                }
        }
    }
}

// Extension to make Task cancellable with Combine
extension Task {
    func eraseToAnyCancellable() -> AnyCancellable {
        AnyCancellable { self.cancel() }
    }
}
