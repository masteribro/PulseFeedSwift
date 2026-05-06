//
//  HomeView.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 02/03/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.feedItems) { item in
                FeedCardView(item: item)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(.plain)
            .navigationTitle("Pulse Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .alert(isPresented: .constant(viewModel.state.error != nil)) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.state.error ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

extension HomeState {
    var error: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}
