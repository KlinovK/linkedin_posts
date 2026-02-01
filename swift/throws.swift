//
//  throws.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 28/01/26.
//

import Foundation

// MARK: - Models

struct User: Codable {
    let id: String
    let name: String
    let avatarURL: String
}

class Profile: Identifiable, Codable {
    var id: String
    var name: String
    var avatar: Data?
    
    init(id: String, name: String, avatar: Data? = nil) {
        self.id = id
        self.name = name
        self.avatar = avatar
    }
    
    // Convenience initializer for creating from User
    convenience init(user: User, avatar: Data?) {
        self.init(id: user.id, name: user.name, avatar: avatar)
    }
}

// MARK: - Errors

enum ValidationError: Error {
    case invalidID
    case invalidURL
}

// MARK: - Network Manager

class NetworkManager {
    private let currentUserID = "123"
    
    func get(_ url: String) async throws -> Data {
        // Simulate network call
        guard let url = URL(string: "https://api.example.com\(url)") else {
            throw ValidationError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    func fetchUserData(id: String) async throws -> User {
        guard !id.isEmpty else {
            throw ValidationError.invalidID
        }
        
        // Network call that might fail
        let data = try await self.get("/users/\(id)")
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    func downloadImage(url: String) async throws -> Data {
        guard !url.isEmpty else {
            throw ValidationError.invalidURL
        }
        
        let data = try await self.get("/images/\(url)")
        return data
    }
    
    // MARK: - Three ways to call throwing functions
    
    // 1. try - Handle with do-catch
    func doCatchExample() async {
        do {
            let user = try await fetchUserData(id: "123")
            print("User fetched: \(user.name)")
        } catch ValidationError.invalidID {
            print("Error: Invalid ID provided")
        } catch {
            print("Error: \(error)")
        }
    }
    
    // 2. try? - Convert to optional
    func convertToOptionalExample() async {
        if let user = try? await fetchUserData(id: "123") {
            print(user.name)
        } else {
            print("Failed to fetch user")
        }
    }
    
    // 3. try! - Force unwrap (use sparingly!)
    func forceUnwrapExample() async {
        let user = try! await fetchUserData(id: "123")
        print(user.name)
    }
    
    // MARK: - Pro tip
    
    // Combine throws with async for modern Swift concurrency
    func loadUserProfile() async throws -> Profile {
        let user = try await fetchUserData(id: currentUserID)
        let avatar = try await downloadImage(url: user.avatarURL)
        return Profile(user: user, avatar: avatar)
    }
}
