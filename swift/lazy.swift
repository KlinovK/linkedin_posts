//
//  lazy.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 22/01/26.
//

import Foundation

// ❌ Eager evaluation: processes ALL 1 million items
let numbers = 1...1_000_000
let result = numbers
    .map { $0 * 2 }           // Creates array of 1M items
    .filter { $0 % 3 == 0 }   // Creates another array
    .prefix(5)                // Finally takes first 5

// ✅ Lazy evaluation: processes only what's needed
let lazyResult = numbers
    .lazy
    .map { $0 * 2 }           // No array created
    .filter { $0 % 3 == 0 }   // No array created
    .prefix(5)                // Stops after finding 5 matches

func testLazy() {
    print(Array(lazyResult)) // [6, 12, 18, 24, 30]
}

