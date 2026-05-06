//
//  AssetDocumentService.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 05/03/2026.
//

import Foundation
import UIKit
import QuickLook
import Combine
import SwiftUI

class AssetDocumentService: NSObject, ObservableObject {
    @Published private(set) var isLoading = false
    @Published var isPDFViewerPresented = false
    
    private var documentUrl: URL?
    private var completionHandler: ((Bool) -> Void)?
    
    func getAssetDocumentPath(fileName: String) -> URL? {
        if let bundlePath = Bundle.main.path(forResource: fileName, ofType: nil) {
            print("✅ Found file at: \(bundlePath)")
            return URL(fileURLWithPath: bundlePath)
        }
        
        if !fileName.hasSuffix(".pdf") {
            let pdfFileName = fileName + ".pdf"
            if let bundlePath = Bundle.main.path(forResource: pdfFileName, ofType: nil) {
                print("✅ Found file with .pdf extension: \(bundlePath)")
                return URL(fileURLWithPath: bundlePath)
            }
        }
        
        let fileNameWithoutExtension = (fileName as NSString).deletingPathExtension
        if let bundlePath = Bundle.main.path(forResource: fileNameWithoutExtension, ofType: "pdf") {
            print("✅ Found file without extension: \(bundlePath)")
            return URL(fileURLWithPath: bundlePath)
        }
        
        print("❌ File not found in bundle: \(fileName)")
        return nil
    }
    
    func listAvailableDocuments() -> [String] {
        guard let resourcePath = Bundle.main.resourcePath else { return [] }
        
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
            return items.filter { $0.hasSuffix(".pdf") }
        } catch {
            print("Error listing documents: \(error)")
            return []
        }
    }
    
    func openAssetDocument(fileName: String, completion: @escaping (Bool) -> Void) {
        guard let fileURL = getAssetDocumentPath(fileName: fileName) else {
            print("❌ Document not found in bundle: \(fileName)")
            completion(false)
            return
        }
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            completion(false)
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            completion(false)
            return
        }
        
        self.completionHandler = completion
        self.documentUrl = fileURL
        
        let pdfViewer = PDFPageViewer(documentURL: fileURL, isPresented: .constant(true))
        let hostingController = UIHostingController(rootView: pdfViewer)
        hostingController.modalPresentationStyle = .fullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        
        rootViewController.present(hostingController, animated: true) { [weak self] in
            self?.completionHandler?(true)
        }
    }
}
