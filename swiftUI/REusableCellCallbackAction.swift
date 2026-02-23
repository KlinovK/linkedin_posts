//
//  REusableCellCallbackAction.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 09/02/26.
//

import Foundation
import SwiftUI

class ItemCustomCell: Identifiable {
    let id = UUID()
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

struct CustomCell: View {
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .cornerRadius(10)
        .onTapGesture {
            onTap()
        }
    }
}

// Usage

struct ListView: View {
    let items: [ItemCustomCell] = [
        ItemCustomCell(name: "Item 1"),
        ItemCustomCell(name: "Item 2"),
        ItemCustomCell(name: "Item 3")
    ]
    
    var body: some View {
        List(items) { item in
            CustomCell(title: item.name) {
                print("Tapped: \(item.name)")
                // Your action here
            }
        }
    }
}

// Advanced: Generic Actions
// For multiple action types:
enum CellAction {
    case tap
    case delete
    case edit
}

struct ActionableCell: View {
    let title: String
    let onAction: (CellAction) -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            
            Button(action: { onAction(.edit) }) {
                Image(systemName: "pencil")
            }
            
            Button(action: { onAction(.delete) }) {
                Image(systemName: "trash")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onAction(.tap) }
    }
}


