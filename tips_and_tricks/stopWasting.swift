//
//  stopWasting.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 04/02/26.
//

import Foundation

class UserName {
    
    func updateUI() {
        
    }
    
    func saveToDatabase() {
        
    }
    
    func notifyObservers() {
        
    }
    
    //  The simple fix

    var username: String = "" {
        didSet {
            guard username != oldValue else { return }
            updateUI()
            saveToDatabase()
            notifyObservers()
        }
    }
    
    //  One line. Massive performance impact.
    
    func update() {
        let oldValue = 5.0
        let newValue = 5.002
        
        guard abs(newValue - oldValue) > 0.001 else {
            return  // Skip update - change too small
        }
        
        // Perform update here
    }

}



