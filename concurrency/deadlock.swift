//
//  deadlock.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 16/02/26.
//

import Foundation
import UIKit

// EXAMPLE 1: Nested Synchronous Dispatch Queue Calls

let queue1 = DispatchQueue(label: "queue1")
let queue2 = DispatchQueue(label: "queue2")

func testNestedQueues() {
    // Thread 1
    queue1.sync {
        queue2.sync {
            // Thread 1 waits for queue2
            print("This won't execute - deadlock!")
        }
    }

    // Thread 2
    queue2.sync {
        queue1.sync {
            // Thread 2 waits for queue1
            print("This won't execute - deadlock!")
        }
    }
}

// EXAMPLE 2: Main Queue Deadlock

func testMainQueueDeadlock() {
    DispatchQueue.main.sync {
        // ❌ DEADLOCK!
        // Already on main queue - trying to synchronously dispatch to itself
        print("This will never execute")
    }
}

// EXAMPLE 3: Serial Queue Recursive Deadlock
let serialQueue = DispatchQueue(label: "serial")

func testRecursiveSerialQueueDeadlock() {
    serialQueue.sync {
        serialQueue.sync {
            // ❌ Waiting for itself. The outer sync blocks the queue, inner sync waits for it
            print("Deadlock - queue waiting on itself")
        }
    }
}

// EXAMPLE 4: Classic Lock-Based Deadlock (Dining Philosophers)

let lock1 = NSLock()
let lock2 = NSLock()

func diningPhilosophers() {
    // Thread A
    DispatchQueue.global().async {
        lock1.lock()
        print("Thread A acquired lock1")
        Thread.sleep(forTimeInterval: 0.1)
        
        lock2.lock() // ⚠️ Waits for Thread B to release lock2
        print("Thread A acquired lock2")
        
        lock2.unlock()
        lock1.unlock()
    }

    // Thread B
    DispatchQueue.global().async {
        lock2.lock()
        print("Thread B acquired lock2")
        Thread.sleep(forTimeInterval: 0.1)
        
        lock1.lock() // ⚠️ Waits for Thread A to release lock1
        print("Thread B acquired lock1")
        
        lock1.unlock()
        lock2.unlock()
    }
}




