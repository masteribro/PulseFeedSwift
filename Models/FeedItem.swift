//
//  FeedItem.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 02/03/2026.
//

import Foundation

struct FeedItem: Identifiable {
    let id = UUID()
    let type: MediaType
    let title: String
    let description: String?
    let mediaUrl: String?
    let assetName: String?
    let fileName: String?
    
    init(type: MediaType, title: String, description: String? = nil,
         mediaUrl: String? = nil, assetName: String? = nil, fileName: String? = nil) {
        self.type = type
        self.title = title
        self.description = description
        self.mediaUrl = mediaUrl
        self.assetName = assetName
        self.fileName = fileName
    }
}

extension FeedItem {
    static var sampleItems: [FeedItem] {
        [
            FeedItem(
                type: .video,
                title: "VideoChannel",
                description: "Watch this cute cat doing tricks 🐱 #Cats #Funny",
                mediaUrl: "https://storage.googleapis.com/exoplayer-test-media-0/BigBuckBunny_320x180.mp4"
            ),
            FeedItem(
                type: .audio,
                title: "PodcastDaily",
                description: "Start your day with this amazing podcast ☀️ #MorningMotivation",
                mediaUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
            ),
            FeedItem(
                type: .document,
                title: "My CV",
                description: "Mohamed Ibrahim's CV 📄",
                assetName: "Mohammed_Ibrahim_CV",  
                fileName: "Mohamed_Ibrahim_CV.pdf"
            ),
            FeedItem(
                type: .text,
                title: "DailyThoughts",
                description: "Just finished building this awesome app! 🚀\n\nFeeling proud of what we've accomplished. The journey of learning Swift has been amazing.\n\n#iOSDev #MobileApps #CodingLife"
            ),
            FeedItem(
                type: .text,
                title: "WeatherUpdate",
                description: "Beautiful sunny day here in California! ☀️ 75°F and perfect for coding."
            ),
            FeedItem(
                type: .text,
                title: "TechNews",
                description: "Breaking: New iOS version just dropped! Check out the amazing new features 🔥"
            )
        ]
    }
}
