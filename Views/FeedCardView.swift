//
//  FeedCardView.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 02/03/2026.
//

import SwiftUI

struct FeedCardView: View {
    let item: FeedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if item.type != .text {
                MediaPreviewView(item: item)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text(String(item.title.prefix(1)).uppercased())
                                .foregroundColor(.white)
                                .font(.system(size: 12, weight: .bold))
                        )
                    
                    Text(item.title)
                        .font(.system(size: 15, weight: .bold))
                }
                
                if let description = item.description {
                    Text(description)
                        .font(.system(size: 16))
                        .lineSpacing(4)
                }
                
                if item.type == .text && item.description == nil {
                    Text("No content")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
