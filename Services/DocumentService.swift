//
//  DocumentService.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 02/03/2026.
//

import Foundation
import UIKit
import QuickLook
import Combine

enum DocumentError: Error {
    case invalidURL
    case downloadFailed
    case fileNotFound
    case cannotOpen
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .downloadFailed: return "Download failed"
        case .fileNotFound: return "File not found"
        case .cannotOpen: return "Cannot open document"
        }
    }
}

class DocumentService: NSObject, ObservableObject, QLPreviewControllerDataSource {
    @Published private(set) var isLoading = false
    @Published private(set) var progress: Double = 0
    
    private var documentUrl: URL?
    private var downloadTask: URLSessionDownloadTask?
    private var progressObserver: NSKeyValueObservation?
    private var completionHandler: ((Bool) -> Void)?
    
    func downloadDocument(url: String, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(DocumentError.invalidURL))
            return
        }
        
        isLoading = true
        progress = 0
        
        let session = URLSession.shared
        downloadTask = session.downloadTask(with: url) { [weak self] localURL, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let localURL = localURL else {
                    completion(.failure(DocumentError.downloadFailed))
                    return
                }
                
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsURL.appendingPathComponent(fileName)
                
                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    try FileManager.default.moveItem(at: localURL, to: destinationURL)
                    completion(.success(destinationURL.path))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        progressObserver = downloadTask?.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            DispatchQueue.main.async {
                self?.progress = progress.fractionCompleted
            }
        }
        
        downloadTask?.resume()
    }
    
    func openDocument(path: String, completion: @escaping (Bool) -> Void) {
        let fileURL = URL(fileURLWithPath: path)
        
        guard FileManager.default.fileExists(atPath: path) else {
            completion(false)
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            completion(false)
            return
        }
        
        self.completionHandler = completion
        documentUrl = fileURL
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self as? QLPreviewControllerDelegate
        
        rootViewController.present(previewController, animated: true)
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return documentUrl != nil ? 1 : 0
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentUrl! as QLPreviewItem
    }
    
    func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        isLoading = false
        progress = 0
    }
    
    deinit {
        progressObserver?.invalidate()
    }
}

extension DocumentService: QLPreviewControllerDelegate {
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        completionHandler?(true)
        documentUrl = nil
    }
}
