//
//  InlineArrayExample.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 08/01/26.
//

import Foundation

struct Color {
    var rgb: InlineArray<3, UInt8>
    
    init(red: UInt8, green: UInt8, blue: UInt8) {
        self.rgb = [red, green, blue]
    }
    
    var red: UInt8 { rgb[0] }
    var green: UInt8 { rgb[1] }
    var blue: UInt8 { rgb[2] }
}


