//
//  DynamicCellSize.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 26/01/26.
//

import SwiftUI

struct DynamicCell: View {
    let title: String
    let description: String
    let imageName: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Dynamic image sizing
            AsyncImage(url: URL(string: imageName)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                EmptyView()
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Dynamic text sizing
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(nil) // Expands as needed
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}

