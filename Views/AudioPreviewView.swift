//
//  AudioPreviewView.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 02/03/2026.
//

import SwiftUI

struct AudioPreviewView: View {
    let mediaUrl: String?
    @EnvironmentObject private var viewModel: HomeViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                guard let url = mediaUrl else { return }
                if case .audioPlaying(true) = viewModel.state {
                    viewModel.pauseAudio()
                } else {
                    viewModel.playAudio(url: url)
                }
            }) {
                Image(systemName: {
                    if case .audioPlaying(true) = viewModel.state {
                        return "pause.circle.fill"
                    } else {
                        return "play.circle.fill"
                    }
                }())
                .font(.system(size: 40))
                .foregroundColor(.white)
            }
            
            Button(action: {
                viewModel.stopAudio()
            }) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
        }
    }
}
