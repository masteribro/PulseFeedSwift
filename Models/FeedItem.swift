//
//  FeedItem.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 02/03/2026.
//

import Foundation

struct FeedItem: Identifiable, Decodable {
    let id: UUID
    let type: MediaType
    let title: String
    let description: String?
    let mediaUrl: String?
    let assetName: String?
    let fileName: String?

    enum CodingKeys: String, CodingKey {
        case url
        case text
        case mediaType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()

        let mediaTypeString = try container.decode(String.self, forKey: .mediaType)
        self.type = MediaType(rawValue: mediaTypeString) ?? .text
        self.title = mediaTypeString.capitalized

        self.description = try container.decodeIfPresent(String.self, forKey: .text)

        let url = try container.decodeIfPresent(String.self, forKey: .url)

        if self.type == .document, let url = url, !url.isEmpty {
            let filename = URL(string: url)?.lastPathComponent ?? url
            self.fileName = filename
            self.assetName = (filename as NSString).deletingPathExtension
            self.mediaUrl = url
        } else {
            self.mediaUrl = (url?.isEmpty == true) ? nil : url
            self.assetName = nil
            self.fileName = nil
        }
    }

    init(type: MediaType, title: String, description: String? = nil,
         mediaUrl: String? = nil, assetName: String? = nil, fileName: String? = nil) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.description = description
        self.mediaUrl = mediaUrl
        self.assetName = assetName
        self.fileName = fileName
    }
}
