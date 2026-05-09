//
//  MediaDataService.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 09/05/2026.
//

import Foundation

class MediaDataService {
    private let baseURL = "http://localhost:8080/api/v1/media-data"

    func fetchMediaData() async throws -> [FeedItem] {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([FeedItem].self, from: data)
    }
}
