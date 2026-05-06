//
//  HomeViewModel.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 02/03/2026.
//

import Foundation
import SwiftUI
import Combine

enum HomeState: Equatable {
    case initial
    case audioPlaying(Bool)
    case videoPlaying(Bool)
    case documentLoading(Bool)
    case documentViewing(String)
    case error(String)
    
    static func == (lhs: HomeState, rhs: HomeState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.audioPlaying(let l), .audioPlaying(let r)):
            return l == r
        case (.videoPlaying(let l), .videoPlaying(let r)):
            return l == r
        case (.documentLoading(let l), .documentLoading(let r)):
            return l == r
        case (.documentViewing(let l), .documentViewing(let r)):
            return l == r
        case (.error(let l), .error(let r)):
            return l == r
        default:
            return false
        }
    }
}

class HomeViewModel: ObservableObject {
    @Published private(set) var state: HomeState = .initial
    @Published var feedItems: [FeedItem] = FeedItem.sampleItems
    
    private let audioService = AudioPlayerService()
    private let videoService = VideoPlayerService()
    private let documentService = DocumentService()
    private let assetDocumentService = AssetDocumentService()  
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        audioService.$isPlaying
            .sink { [weak self] isPlaying in
                self?.state = .audioPlaying(isPlaying)
            }
            .store(in: &cancellables)
        
        videoService.$isPlaying
            .sink { [weak self] isPlaying in
                self?.state = .videoPlaying(isPlaying)
            }
            .store(in: &cancellables)
        
        documentService.$isLoading
            .sink { [weak self] isLoading in
                self?.state = .documentLoading(isLoading)
            }
            .store(in: &cancellables)
    }
    
    func playAudio(url: String) {
        audioService.play(url: url)
    }
    
    func pauseAudio() {
        audioService.pause()
    }
    
    func stopAudio() {
        audioService.stop()
    }
    
    func playVideo(url: String) {
        videoService.play(url: url)
    }
    
    func pauseVideo() {
        videoService.pause()
    }
    
    func stopVideo() {
        videoService.stop()
    }
    

    func viewAssetDocument(assetName: String, fileName: String) {
        print("🟡 Attempting to open asset document: \(assetName)")
        state = .documentLoading(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.assetDocumentService.openAssetDocument(fileName: assetName) { success in
                DispatchQueue.main.async {
                    self.state = .documentLoading(false)
                    if success {
                        print("✅ Document opened successfully with horizontal swiping")
                        if let path = self.assetDocumentService.getAssetDocumentPath(fileName: assetName)?.path {
                            self.state = .documentViewing(path)
                        }
                    } else {
                        print("❌ Failed to open document")
                        self.state = .error("Failed to open document from assets")
                    }
                }
            }
        }
    }
    
    
    func viewDocument(url: String, fileName: String) {
        state = .documentLoading(true)
        
        documentService.downloadDocument(url: url, fileName: fileName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let filePath):
                    self?.documentService.openDocument(path: filePath) { success in
                        if success {
                            self?.state = .documentViewing(filePath)
                        } else {
                            self?.state = .error("Failed to open document")
                        }
                    }
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func downloadDocument(url: String, fileName: String) {
        state = .documentLoading(true)
        
        documentService.downloadDocument(url: url, fileName: fileName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let filePath):
                    self?.state = .documentLoading(false)
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func openDocument(path: String) {
        documentService.openDocument(path: path) { [weak self] success in
            if success {
                self?.state = .documentViewing(path)
            } else {
                self?.state = .error("Failed to open document")
            }
        }
    }
}
