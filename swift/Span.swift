//
//  Span.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 18/01/26.
//

import Foundation

func testSpan() {
    var numbers = [10, 20, 30, 40, 50, 60]

    // Access the array as a Span using the .span property
    let s: Span<Int> = numbers.span

    // Iterate through the span - zero-copy, bounds-checked access
    for i in 0..<s.count {
        print(s[i])
    }

    // Function that works with any contiguous buffer
    func processData(_ data: Span<Int>) {
        for i in 0..<data.count {
            print("Processing: \(data[i])")
        }
    }
    
    processData(numbers.span) // Works with Array, ArraySlice, InlineArray, etc.
}


