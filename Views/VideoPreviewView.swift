//
//  VideoPreviewView.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 02/03/2026.
//

import SwiftUI

struct VideoPreviewView: View {
    let mediaUrl: String?
    @EnvironmentObject private var viewModel: HomeViewModel
    
    var body: some View {
        Button(action: {
            guard let url = mediaUrl else { return }
            if case .videoPlaying(true) = viewModel.state {
                viewModel.pauseVideo()
            } else {
                viewModel.playVideo(url: url)
            }
        }) {
            Image(systemName: {
                if case .videoPlaying(true) = viewModel.state {
                    return "pause.circle.fill"
                } else {
                    return "play.circle.fill"
                }
            }())
            .font(.system(size: 50))
            .foregroundColor(.white)
        }
    }
}
