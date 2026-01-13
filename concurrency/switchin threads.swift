//
//  switchin threads.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 14/01/26.
//

import SwiftUI
import UIKit

struct User: Codable {
    let name: String
}

class SwiftThreads {
    
    let imageView = UIImageView()
    let nameLabel = UILabel()
    let url = URL(string: "https://api.example.com/user")!
    let userURL = URL(string: "https://api.example.com/user")!
    let postsURL = URL(string: "https://api.example.com/posts")!
    
    // 1. GCD - The Classic
    func processImage(_ image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let processed = image // Apply your filters here
            DispatchQueue.main.async {
                self?.imageView.image = processed
            }
        }
    }

    // 2. async/await - The Modern Way
    func loadProfile() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let user = try JSONDecoder().decode(User.self, from: data)
            nameLabel.text = user.name  // Auto main thread
        } catch {
            showError(error)
        }
    }

    // 3. DispatchGroup - For Coordination
    func loadDashboard() {
        let group = DispatchGroup()
        
        group.enter()
        URLSession.shared.dataTask(with: userURL) { _, _, _ in
            group.leave()
        }.resume()
        
        group.enter()
        URLSession.shared.dataTask(with: postsURL) { _, _, _ in
            group.leave()
        }.resume()
        
        group.notify(queue: .main) {
            self.updateUI()  // All tasks completed!
        }
    }
    
    func showError(_ error: Error) {
        print("Error: \(error)")
    }
    
    func updateUI() {
        print("UI Updated!")
    }
}

