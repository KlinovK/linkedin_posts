//
//  BitManiulation.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 23/02/26.
//

import Foundation

struct Permissions: OptionSet {
    let rawValue: Int
    static let camera   = Permissions(rawValue: 1 << 0) // 001
    static let mic      = Permissions(rawValue: 1 << 1) // 010
    static let location = Permissions(rawValue: 1 << 2) // 100
}

// Check for a specific bit (Fast & Clean)
let currentAccess: Permissions = [.camera, .location]

func hasCameraAccess(_ permissions: Permissions) -> Bool {
    return permissions.contains(.camera)
}



