//
//  overengi.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 02/02/26.
//

import Foundation
import SwiftUI
import Combine

class ItemExample {
    var price: Double
    init(price: Double) { self.description = "Item"; self.description = price }
}

struct UserForExample {
    let id: Int
    let name: String
}

// Mock fetch function
func fetchUser(id: Int) async throws -> UserForExample {
    // Simulate network delay
    try await Task.sleep(nanoseconds: 100_000_000)
    
    // Mock user data
    return UserForExample(id: id, name: "User \(id)")
}

// CASE 1: Async for synchronous work
// ==========================================

// Over-engineered
func calculateTotal(items: [ItemExample]) async -> Double {
    items.reduce(into: 0) { $0 += $1.price }
}

// Simple
func calculateTotal(items: [ItemExample]) -> Double {
    items.reduce(into: 0) { $0 += $1.price }
}


// CASE 2: Actor for every object
// ==========================================

// Over-engineered
actor UserPreferencesActor {
    private var theme: String = "light"
    func setTheme(_ newTheme: String) { theme = newTheme }
}

// Better
@MainActor
class UserPreferences: ObservableObject {
    @Published var theme: String = "light"
}

// CASE 3: Complex TaskGroup
// ==========================================

// Over-engineered
func fetchUsersOverEngineered() async throws -> [UserForExample] {
    let userIds = [1, 2, 3, 4, 5]

    return try await withThrowingTaskGroup(of: UserForExample.self) { group in
        for id in userIds {
            group.addTask { try await fetchUser(id: id) }
        }
        var users: [UserForExample] = []
        for try await user in group {
            users.append(user)
        }
        return users
    }
}

// Simple
func fetchUsers() async throws -> [UserForExample] {
    let userIds = [1, 2, 3, 4, 5]

    return try await withThrowingTaskGroup(of: UserForExample.self) { group in
        userIds.forEach { id in
            group.addTask { try await fetchUser(id: id) }
        }
        return try await group.reduce(into: []) { $0.append($1) }
    }
}

// Even simpler for 2-3 items
func fetchUserData() async throws -> (UserForExample, Profile, String) {
    async let user = fetchUser()
    async let profile = fetchProfile()
    async let settings = fetchSettings()
    
    return try await (user, profile, settings)
}

// You'll need these async functions defined:
func fetchUser() async throws -> UserForExample {
    // Your implementation
}

func fetchProfile() async throws -> Profile {
    // Your implementation
}

func fetchSettings() async throws -> String {
    // Your implementation
}
// Example ViewModel
class ViewModelOverEngineered {
    func fetchData() async {
        // Async work here
    }
}

class DataController {
    let viewModel = ViewModelOverEngineered() // Need viewModel property
    
    // CASE 4: Unnecessary Task wrapping
    // ==========================================
    
    // Over-engineered - unnecessary Task wrapper
    func loadData() {
        Task {
            await viewModel.fetchData()
        }
    }

    // Better - already in async context
    func loadData() async {
        await viewModel.fetchData()
    }

    // Only when bridging sync → async
    // Must be in a class to use @objc
    @objc func buttonTapped() {
        Task { await loadData() }
    }
}
// CASE 5: Custom AsyncSequence
// ==========================================

// Over-engineered
struct NumberStream: AsyncSequence {
    typealias Element = Int
    
    struct AsyncIterator: AsyncIteratorProtocol {
        var current = 0
        let max: Int
        
        mutating func next() async -> Int? {
            guard current < max else { return nil }
            current += 1
            return current
        }
    }
    
    let max: Int
    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(max: max)
    }
}

// Simple
func numberStream(max: Int) -> AsyncStream<Int> {
    AsyncStream { continuation in
        for i in 1...max {
            continuation.yield(i)
        }
        continuation.finish()
    }
}

// Define the types we need
struct ProcessedData {
    let value: String
}


// CASE 6: MainActor everywhere
// ==========================================

// Over-engineered
@MainActor
class DataManagerOverEngineered {
    func processData(_ data: Data) -> ProcessedData {
        // Heavy work on main thread - BAD!
        return heavyProcessing(data)
    }
    
    private func heavyProcessing(_ data: Data) -> ProcessedData {
        // Simulate heavy processing
        let result = String(data: data, encoding: .utf8) ?? ""
        return ProcessedData(value: result.uppercased())
    }
}

// Better
class DataManagerBetter {
    @MainActor
    private var displayData: ProcessedData?
    
    func processData(_ data: Data) -> ProcessedData {
        heavyProcessing(data) // Runs on background thread
    }
    
    @MainActor
    func updateUI(with data: ProcessedData) {
        self.displayData = data
    }
    
    private func heavyProcessing(_ data: Data) -> ProcessedData {
        // Simulate heavy processing
        let result = String(data: data, encoding: .utf8) ?? ""
        return ProcessedData(value: result.uppercased())
    }
}

// Mock database for example
actor Database {
    func save(_ data: Data) async {
        // Save implementation
    }
}

class DataManagerEx {
    let database = Database()
    
    // CASE 7: Detached Tasks
    // ==========================================
    
    // Over-engineered (loses priority and context)
    func saveDataOverEngineered(data: Data) {
        Task.detached { [database] in
            await database.save(data)
        }
    }
    
    // Better (inherits priority and context, cleaner capture)
    func saveData(data: Data) {
        Task {
            await self.database.save(data)
        }
    }
}


class DataLoader {
    private var task: Task<Void, Never>?
    
    // CASE 8: Over-checking cancellation
    // ==========================================
    
    // Over-engineered - manually checking cancellation at every step
    func loadOverEngineered() {
        task = Task {
            guard !Task.isCancelled else { return }
            try? await fetchData()
            
            guard !Task.isCancelled else { return }
            try? await processData()
            
            guard !Task.isCancelled else { return }
            try? await saveData()
        }
    }
    
    // Simple - trust Swift's cooperative cancellation
    func load() {
        task = Task {
            try? await fetchData()
            try? await processData()
            try? await saveData()
        }
    }
    
    // Mock async functions
    private func fetchData() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("Data fetched")
    }
    
    private func processData() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("Data processed")
    }
    
    private func saveData() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("Data saved")
    }
    
    func cancel() {
        task?.cancel()
    }
    
    // Mock async functions
    private func fetchDataOver() async  {
        await Task.sleep(nanoseconds: 1_000_000_000)
        print("Data fetched")
    }
    
    private func processDataOver() async  {
        await Task.sleep(nanoseconds: 1_000_000_000)
        print("Data processed")
    }
    
    private func saveDataOver() async {
        await Task.sleep(nanoseconds: 1_000_000_000)
        print("Data saved")
    }
    
    
}

