//
//  asynclet.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 27/01/26.
//

import Foundation

func fetchOptional1() async throws -> String {
    try await Task.sleep(for: .seconds(1))
    throw NetworkError.timeout  // This will fail!
}

func fetchOptional2() async throws -> String {
    try await Task.sleep(for: .seconds(2))
    return "Optional 2"
}

func fetchCriticalData() async throws -> String {
    try await Task.sleep(for: .seconds(3))
    return "Critical Data"  // This completes successfully!
}

enum NetworkError: Error {
    case serverUnavailable
}

class Analytics {
    let views: Int
    init(views: Int) { self.views = views }
}

class UserProfile {
    let name: String
    init(name: String) { self.name = name }
}

class DashboardData {
    let userProfile: UserProfile
    let notifications: [Notification]
    let analytics: Analytics
    init(userProfile: UserProfile, notifications: [Notification], analytics: Analytics) {
        self.userProfile = userProfile
        self.notifications = notifications
        self.analytics = analytics
    }
}

// Example implementation showing the failure:
func fetchNotifications() async throws -> [Notification] {
    try await Task.sleep(for: .seconds(2))
    throw NetworkError.serverUnavailable  // 💥 This fails
}

func fetchAnalytics() async throws -> Analytics {
    try await Task.sleep(for: .seconds(4))  // This would take longer...
    // ⚠️ But it gets cancelled before completion!
    // No wasted work, no zombie tasks
    return Analytics(views: 1000)
}

func fetchUserProfile() async -> UserProfile {
    try await Task.sleep(for: .seconds(1))
    return UserProfile(name: "John Doe")
}

func fetchDashboardData() async throws -> DashboardData {
    async let userProfile = fetchUserProfile()      // ← Task 1 starts
    async let notifications = fetchNotifications()  // ← Task 2 starts
    async let analytics = fetchAnalytics()          // ← Task 3 starts
    
    // All three tasks running concurrently...
    //
    // Timeline visualization:
    // ┌─────────────────────────────────────┐
    // │ userProfile    [████████████] ✅     │
    // │ notifications  [████] ❌ THROWS      │
    // │ analytics      [████████] ⚠️ CANCELLED │
    // └─────────────────────────────────────┘
    //
    // When notifications fails:
    // 1. Swift immediately cancels analytics (still running)
    // 2. userProfile already completed, so no action needed
    // 3. The error propagates up
    
    return try await DashboardData(
        userProfile: userProfile,
        notifications: notifications,  // ← Throws here!
        analytics: analytics           // ← Never reached, already cancelled
    )
}

func loadMixedData() async throws -> String {
    // This task is NOT a sibling of the ones in the do block
    async let criticalData = fetchCriticalData()
    
    do {
        async let optionalData1 = fetchOptional1()
        async let optionalData2 = fetchOptional2()
        
        // Only these two are siblings - if one fails, the other cancels
        let data = try await (optionalData1, optionalData2)
        print("Optional data: \(data)")
    } catch {
        // optionalData1 threw an error, optionalData2 was cancelled
        // BUT criticalData keeps running! 🎯
        print("Optional data failed, but that's okay")
    }
    
    // criticalData completes successfully despite the failure above
    let result = try await criticalData
    return result  // Returns: "Critical Data"
}
