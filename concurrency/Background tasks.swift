//
//  Background tasks.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 07/02/26.
//

import Foundation
import BackgroundTasks

// iOS Background Tasks Quick Guide

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    private let taskID = "com.yourapp.refresh"
    
    // Register task (call in AppDelegate)
    func register() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskID,
            using: nil
        ) { task in
            self.handleRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    // Schedule task
    func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        try? BGTaskScheduler.shared.submit(request)
    }
    
    // Handle task
    private func handleRefresh(task: BGAppRefreshTask) {
        schedule() // Re-schedule next run
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Do your work
        fetchData { success in
            task.setTaskCompleted(success: success)
        }
    }
    
    private func fetchData(completion: @escaping (Bool) -> Void) {
        URLSession.shared.dataTask(
            with: URL(string: "https://api.example.com/data")!
        ) { data, _, error in
            completion(error == nil)
        }.resume()
    }
}

// Setup in AppDelegate:
/*
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions...) -> Bool {
    BackgroundTaskManager.shared.register()
    return true
}

func applicationDidEnterBackground(_ application: UIApplication) {
    BackgroundTaskManager.shared.schedule()
}
*/

// Info.plist - Add:
// BGTaskSchedulerPermittedIdentifiers: ["com.yourapp.refresh"]
