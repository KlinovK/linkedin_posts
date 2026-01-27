//
//  TypeErasure.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 23/01/26.
//

import Foundation

// 1. The Protocol with an Associated Type (The Problem)
// We cannot use 'Fetcher' as a variable type directly because Swift
// doesn't know what 'DataType' will be.
protocol Fetcher {
    associatedtype DataType
    func fetch() -> DataType
}

// 2. Concrete Implementations
struct UserFetcher: Fetcher {
    func fetch() -> String { "User: John Doe" }
}

struct ProductFetcher: Fetcher {
    func fetch() -> String { "Product: Swift Book" }
}

// 3. The Type Erasure Wrapper (The Solution)
// This struct "erases" the underlying concrete type, keeping only the interface.
struct AnyFetcher<T>: Fetcher {
    private let _fetch: () -> T
    
    // We inject the concrete fetcher here
    init<F: Fetcher>(_ fetcher: F) where F.DataType == T {
        self._fetch = fetcher.fetch
    }
    
    func fetch() -> T {
        return _fetch()
    }
}

// 4. Real-world Usage
// Without erasure, [Fetcher] is a compile error.
// With erasure, we can mix different concrete types that share the same output type.
let fetchers: [AnyFetcher<String>] = [
    AnyFetcher(UserFetcher()),
    AnyFetcher(ProductFetcher())
]

func testFetcher() {
    for fetcher in fetchers {
        print(fetcher.fetch())
    }
}
