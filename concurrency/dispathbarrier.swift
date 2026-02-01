//
//  dispathbarrier.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 01/02/26.
//

import Foundation

class DispatchQueueWrapper {
    
    // Create a concurrent queue that allows multiple read operations simultaneously
    // but ensures write operations have exclusive access
    let queue = DispatchQueue(label: "data.queue", attributes: .concurrent)

    var sharedData: [String] = []

    func readData(id: Int) {
        // Run read operation asynchronously on the concurrent queue
        // Multiple readers can execute at the same time
        queue.async { [weak self] in
            guard let self = self else { return }
            // Safe to read because no writer is active
            print("Reader \(id): \(self.sharedData)")
        }
    }

    func writeData(item: String) {
        // The .barrier flag ensures this task waits for all current tasks to finish
        // and prevents new tasks from starting until this one completes
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            print("Writer acquiring exclusive access...")
            // Safe to modify because we have exclusive access
            self.sharedData.append(item)
            print("Writer added '\(item)'. Array now: \(self.sharedData)")
        }
    }

}

