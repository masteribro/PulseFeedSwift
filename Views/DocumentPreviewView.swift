//
//  DocumentPreviewView.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 02/03/2026.
//

import SwiftUI

struct DocumentPreviewView: View {
    let mediaUrl: String?
    let assetName: String?
    let fileName: String?
    @EnvironmentObject private var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            if case .documentLoading(true) = viewModel.state {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Text("Loading document...")
                    .font(.caption)
                    .foregroundColor(.white)
            } else {
                Button(action: {
                    if let assetName = assetName, let name = fileName {
                        viewModel.viewAssetDocument(assetName: assetName, fileName: name)
                    } else if let url = mediaUrl, let name = fileName {
                        viewModel.viewDocument(url: url, fileName: name)
                    }
                }) {
                    VStack {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                        Text("View PDF")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}
