//
//  Copying.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 17/01/26.
//

import Foundation

class Recipe: NSObject, NSCopying {
    var name: String
    var ingredients: [String]
    
    init(name: String, ingredients: [String]) {
        self.name = name
        self.ingredients = ingredients
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Recipe(name: name, ingredients: ingredients)
    }
}

func testCopy() {
    let original = Recipe(name: "Chocolate Cake", ingredients: ["Banana", "Sugar"])
    let modified = original.copy() as! Recipe  // True copy!

    modified.name = "Vanilla Cake"
    print(original.name)  // "Chocolate Cake" - Safe!
}

