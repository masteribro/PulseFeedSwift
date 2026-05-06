//
//  PDFViewerContainer.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 05/03/2026.
//

import SwiftUI

struct PDFViewerContainer: View {
    let fileURL: URL
    @Binding var isPresented: Bool
    
    var body: some View {
        PDFPageViewer(documentURL: fileURL, isPresented: $isPresented)
            .edgesIgnoringSafeArea(.all)
    }
}
