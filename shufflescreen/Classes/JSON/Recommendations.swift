//
//  Recommendations.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 08/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import Foundation

// MARK: - Recommendations
class Recommendations: Codable {
    let tracks: [Track]?
    let seeds: [Seed]?

    init(tracks: [Track]?, seeds: [Seed]?) {
        self.tracks = tracks
        self.seeds = seeds
    }
}

// MARK: - Seed
class Seed: Codable {
    let initialPoolSize, afterFilteringSize, afterRelinkingSize: Int?
    let href: String?
    let id, type: String?

    init(initialPoolSize: Int?, afterFilteringSize: Int?, afterRelinkingSize: Int?, href: String?, id: String?, type: String?) {
        self.initialPoolSize = initialPoolSize
        self.afterFilteringSize = afterFilteringSize
        self.afterRelinkingSize = afterRelinkingSize
        self.href = href
        self.id = id
        self.type = type
    }
}

// MARK: - Track
class Track: Codable {
    let artists: [Artist]?
    let discNumber, durationMS: Int?
    let explicit: Bool?
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let isPlayable: Bool?
    let name: String?
    let previewURL: String?
    let trackNumber: Int?
    let type, uri: String?

    enum CodingKeys: String, CodingKey {
        case artists
        case discNumber = "disc_number"
        case durationMS = "duration_ms"
        case explicit
        case externalUrls = "external_urls"
        case href, id
        case isPlayable = "is_playable"
        case name
        case previewURL = "preview_url"
        case trackNumber = "track_number"
        case type, uri
    }

    init(artists: [Artist]?, discNumber: Int?, durationMS: Int?, explicit: Bool?, externalUrls: ExternalUrls?, href: String?, id: String?, isPlayable: Bool?, name: String?, previewURL: String?, trackNumber: Int?, type: String?, uri: String?) {
        self.artists = artists
        self.discNumber = discNumber
        self.durationMS = durationMS
        self.explicit = explicit
        self.externalUrls = externalUrls
        self.href = href
        self.id = id
        self.isPlayable = isPlayable
        self.name = name
        self.previewURL = previewURL
        self.trackNumber = trackNumber
        self.type = type
        self.uri = uri
    }
}

// MARK: - Artist
class Artist: Codable {
    let externalUrls: ExternalUrls?
    let href: String?
    let id, name, type, uri: String?

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, name, type, uri
    }

    init(externalUrls: ExternalUrls?, href: String?, id: String?, name: String?, type: String?, uri: String?) {
        self.externalUrls = externalUrls
        self.href = href
        self.id = id
        self.name = name
        self.type = type
        self.uri = uri
    }
}

// MARK: - ExternalUrls
class ExternalUrls: Codable {
    let spotify: String?

    init(spotify: String?) {
        self.spotify = spotify
    }
}
