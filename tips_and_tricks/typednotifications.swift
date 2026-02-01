//
//  typednotifications.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 31/01/26.
//

import Foundation

class TestObserver: NSObject {
    
    @objc func handleLogin(_ notification: Notification) {
        
    }
    
    func testNotificationsOldWay() {
        let userId = "12345"
        
        // The old way
        NotificationCenter.default.post(
            name: Notification.Name("UserDidLogin"),
            object: nil,
            userInfo: ["userId": userId]
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogin(_:)),
            name: Notification.Name("UserDidLogin"),
            object: nil
        )
        
    }
}

// The new way
// Protocol to associate types with notification names
protocol NotificationDescriptor {
    static var notificationName: Notification.Name { get }
}

// Define your notification as a type
struct UserDidLoginNotification: NotificationDescriptor {
    let userId: String
    let timestamp: Date
    
    static let notificationName = Notification.Name.userDidLogin
}

extension Notification.Name {
    static let userDidLogin = Notification.Name("UserDidLogin")
}

extension NotificationCenter {
    func post<T: NotificationDescriptor>(_ notification: T) {
        post(name: T.notificationName, object: notification)
    }
    
    func observe<T: NotificationDescriptor>(_ type: T.Type, using block: @escaping (T) -> Void) -> NSObjectProtocol {
        addObserver(forName: T.notificationName, object: nil, queue: nil) { note in
            if let value = note.object as? T {
                block(value)
            }
        }
    }
}

// Now use it with full type safety
func testNewNotifications() {
    // Use the shared default instance
    let notificationCenter = NotificationCenter.default
    
    // First observe, then post
    let observer = notificationCenter.observe(UserDidLoginNotification.self) { notification in
        print("User \(notification.userId) logged in at \(notification.timestamp)")
    }
    
    notificationCenter.post(UserDidLoginNotification(
        userId: "user123",
        timestamp: Date()
    ))
    
    // Don't forget to remove observer when done
    // notificationCenter.removeObserver(observer)
}
