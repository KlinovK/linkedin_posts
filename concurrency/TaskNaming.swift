//
//  TaskNaming.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 12/02/26.
//

import Foundation

class TaskNaming {
    
    func heavyComputation() async throws {
        
    }
    
    func exmapleWithNaming() async throws {
        Task(priority: .high) {
            // Anonymous task - hard to debug
        }

        // vs

        Task(name: "ImageDownloader", priority: .high) {
            // Now you can see exactly what's running!
        }
    }
    
}
