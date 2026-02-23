//
//  DataStruvtures.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 14/02/26.
//

import Foundation

struct DataStruvtures {
    func test() {
        
        // 1. Array: Ordered collection with index-based access
        var playlist = ["Song1", "Song2", "Song3"]  // Initialize with 3 items

        // Adding elements
        playlist.append("Song4")  // Add to end → ["Song1", "Song2", "Song3", "Song4"], O(1) operation - very fast!

        // Accessing elements by index (zero-based)
        playlist[1]  // Access 2nd song → "Song2", O(1) operation - instant access!

        // Removing elements
        playlist.remove(at: 0)  // Remove first → ["Song2", "Song3", "Song4"], O(n) operation - shifts all elements left


        // 2. Dictionary: Key-value pairs for fast lookups
        var contacts = ["Alice": "555-0001", "Bob": "555-0002"]  // Initialize with key-value pairs

        // Accessing values by key
        contacts["Alice"]  // → Optional("555-0001"), Returns Optional because key might not exist, O(1) operation - instant lookup!

        // Adding new key-value pairs
        contacts["Charlie"] = "555-0003"  // Add new contact, O(1) operation

        // Removing entries (set value to nil)
        contacts["Bob"] = nil  // Remove Bob from contacts, O(1) operation

        // 3. Set: Unordered collection of unique elements
        var guestList: Set = ["Alice", "Bob", "Charlie"]  // Must specify Set type, No duplicates allowed!

        // Adding elements
        guestList.insert("Alice")  // No duplicate added - Alice already exists, Returns (inserted: false, memberAfterInsert: "Alice")
                                   // O(1) operation

        // Checking membership
        _ = guestList.contains("Bob")  // → true, O(1) operation - much faster than Array!

        // Removing elements
        guestList.remove("Charlie")  // Removes Charlie from set, Returns Optional("Charlie") if found, O(1) operation

        // 4. Stack: LIFO (Last In, First Out) - like a stack of plates
        var history = [String]()  // Empty array used as stack

        // Push - add to top of stack
        history.append("google.com")  // Stack: ["google.com"], Stack: ["google.com", "github.com"], O(1) operation

        // Pop - remove from top of stack
        _ = history.popLast()  // → Optional("github.com") - most recently added, Stack now: ["google.com"]
                           // O(1) operation - returns nil if empty

        // Peek - look at top without removing
        _ = history.last  // → Optional("google.com") - see top element, Doesn't modify the stack

        // 5. Queue: FIFO (First In, First Out) - like a line at a store
        var coffeeQueue = [String]()  // Empty array used as queue

        // Enqueue - add to back of line
        coffeeQueue.append("Alice")  // Queue: ["Alice"], O(1) operation

        // Dequeue - remove from front of line
        coffeeQueue.removeFirst()  // → "Alice" - first person in line served, O(n) operation - not ideal for large queues!

        // Peek - look at front without removing
        _ = coffeeQueue.first  // → Optional("Bob") - who's next in line?

        // 6. Linked List: Each node points to the next node in sequence
        // Great for insertions/deletions, but slower for random access

        class Node<T> {
            var value: T          // Data stored in this node
            var next: Node?       // Reference to next node (nil if last node)
            
            init(_ value: T) {
                self.value = value
            }
        }
        
        // Why use Linked List?
        // ✅ Insert/delete at known position: O(1)
        // ❌ Random access: O(n) - must traverse from start
        // ✅ Dynamic size - grows/shrinks easily
        // ❌ More memory - stores value + pointer per node

        // 7. Binary Tree: Each node has up to 2 children (left and right)
        // Used for hierarchical data and efficient searching

        class TreeNode<T> {
            var value: T           // Data stored in this node
            var left: TreeNode?    // Left child (smaller values in BST)
            var right: TreeNode?   // Right child (larger values in BST)
            
            init(_ value: T) {
                self.value = value
            }
        }

        // Example: Building a Binary Search Tree (BST)
        //       5
        //      / \
        //     3   7
        //    / \   \
        //   1   4   9

        // 8. Graph: Nodes (vertices) connected by edges
        // Represents relationships between entities

        class Graph {
            // Adjacency List: Each node maps to its connected nodes
            var adjacencyList: [String: [String]] = [:]
            
            // Example: Social Network
            //    Alice --- Bob
            //      |        |
            //    Charlie  Diana
        }
    }
}

