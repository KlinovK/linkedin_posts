//
//  Continue.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 09/01/26.
//

import Foundation

func testContinue() {
    
    // Example 1: Skipping odd numbers in a simple for-in loop
    let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    for number in numbers {
        // If the number is odd, skip the rest of this iteration
        // and move to the next number immediately
        if number % 2 == 1 {
            continue  // Skip odd numbers
        }
        
        // This line only executes for even numbers
        print("Even: \(number)")
    }

    // Example 2: Using 'guard' with 'continue' for early filtering

    let files = ["photo.jpg", "document.pdf", "image.png", "script.txt"]

    for file in files {
        guard file.hasSuffix(".jpg") else {
            continue  // Skip non-JPG files
        }
        
        // Only JPG files reach this point
        print("Processing image: \(file)")
    }

    // Example 3: Labeled 'continue' in nested loops

    outerLoop: for i in 1...5 {
        for j in 1...5 {
            if i + j < 8 {
                continue outerLoop
            }
            
            // Only valid pairs (i + j >= 8) are printed
            print("Valid pair: (\(i), \(j))")
        }
    }
}
