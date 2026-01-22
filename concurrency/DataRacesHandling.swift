//
//  DataRacesHandling.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 20/01/26.
//

import Combine
import SwiftUI

// MARK: - 1. Actors - The Modern Way

actor BankAccount {
    private var balance: Double = 0
    
    func deposit(_ amount: Double) {
        balance += amount
    }
    
    func getBalance() -> Double { balance }
}

func testBankAccount() async {
    // Usage
    let account = BankAccount()
    await account.deposit(100)
}

// MARK: - 2. Sendable Protocol

struct UserSendable: Sendable {
    let id: Int
    let name: String
}

// Compile-time safety for concurrent code
func processUser(_ user: UserSendable) async {
    // Safe to pass across tasks
}

// MARK: - 3. @MainActor for UI

func fetchFromAPI() async -> [Item] {
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    return []
}

@MainActor
class ViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    func loadItems() async {
        let data = await fetchFromAPI()
        self.items = data // Always on main thread ✅
    }
}

// MARK: - 4. Dispatch Queues (Legacy)

class DataManager {
    private let queue = DispatchQueue(
        label: "com.app.data"
    )
    private var data: [String] = []
    
    func addItem(_ item: String) {
        queue.async {
            self.data.append(item)
        }
    }
}

// MARK: - 5. Locks - Fine-Grained Control

class Counter {
    private var value = 0
    private let lock = NSLock()
    
    func increment() {
        lock.lock()
        defer { lock.unlock() } // Always unlocks!
        value += 1
    }
}

// MARK: - 6. Immutability - The Best Defense

struct Configuration: Sendable {
    let apiKey: String
    let baseURL: URL
    // All let properties = Thread-safe by default
}

// MARK: - 7. Task Groups - Structured Concurrency

func process(_ item: Item) async -> Result {
    // Simulate async work (API call, computation, etc.)
    try? await Task.sleep(nanoseconds: 100_000_000)
    return Result(value: "success")
}

func processItems(_ items: [Item]) async -> [Result] {
    await withTaskGroup(of: Result.self) { group in
        for item in items {
            group.addTask {
                await process(item)
            }
        }
        
        var results: [Result] = []
        for await result in group {
            results.append(result)
        }
        return results
    }
}
