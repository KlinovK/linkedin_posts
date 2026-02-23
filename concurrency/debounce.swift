import Foundation
import Combine

// MARK: - Protocol

protocol SearchAPI {
    func fetchResults(for query: String) async -> [String]
}

// MARK: - Debug Implementation

class DebugSearchAPI: SearchAPI {

    // MARK: - Properties

    private var results: [String] = []
    private let api = SearchService()

    private var cancellables = Set<AnyCancellable>()
    private let searchTextSubject = PassthroughSubject<String, Never>()
    
    @discardableResult
    func fetchResults(for query: String) async -> [String] {
        return await api.search(query)
    }

    // MARK: - Before: imperative chaos

    var debounceTimer: Timer?

    func searchTextDidChange(_ text: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            guard !text.isEmpty else { return }
            Task {
                await self.fetchResults(for: text)
            }
        }
    }
    
    // MARK: - After: clean, declarative, and concurrency-native
        
    private var searchTextStream: AsyncStream<String> {
        AsyncStream { continuation in
            let cancellable = searchTextSubject
                .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                .sink { continuation.yield($0) }
            continuation.onTermination = { _ in cancellable.cancel() }
        }
    }

    func searchWithStreamAndDebounce() async {
        for await query in searchTextStream {
            guard !query.isEmpty else { continue }
            results = await api.search(query)
        }
    }
}

// MARK: - Search Service

private class SearchService {
    func search(_ query: String) async -> [String] {
        try? await Task.sleep(nanoseconds: 500_000_000)
        return ["Result for \"\(query)\""]
    }
}
