//
//  MediaPreviewView.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 02/03/2026.
//

import SwiftUI

struct MediaPreviewView: View {
    let item: FeedItem
    @EnvironmentObject private var viewModel: HomeViewModel
    
    var body: some View {
        Group {
            switch item.type {
            case .video:
                VideoPreviewView(mediaUrl: item.mediaUrl)
            case .audio:
                AudioPreviewView(mediaUrl: item.mediaUrl)
            case .document:
                DocumentPreviewView(
                    mediaUrl: item.mediaUrl,
                    assetName: item.assetName,
                    fileName: item.fileName
                )
            case .text:
                EmptyView()
            }
        }
        .environmentObject(viewModel)
    }
}
