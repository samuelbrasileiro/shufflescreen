//
//  Playlists.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 08/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import Foundation

// MARK: - Playlists
struct Playlists: Codable {
    let href: String
    let items: [Item]
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
}

// MARK: - Item
struct Item: Codable {
    let collaborative: Bool
    let itemDescription: String
    let externalUrls: ExternalUrlsStruct
    let href: String
    let id: String
    let images: [ImageStruct]
    let name: String
    let owner: Owner
    let primaryColor: String?
    let itemPublic: Bool
    let snapshotID: String
    let tracks: TracksStruct
    let type: ItemType
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case collaborative
        case itemDescription = "description"
        case externalUrls = "external_urls"
        case href, id, images, name, owner
        case primaryColor = "primary_color"
        case itemPublic = "public"
        case snapshotID = "snapshot_id"
        case tracks, type, uri
    }
}

// MARK: - ExternalUrls
struct ExternalUrlsStruct: Codable {
    let spotify: String
}

// MARK: - Image
struct ImageStruct: Codable {
    let height: Int?
    let url: String
    let width: Int?
}

// MARK: - Owner
struct Owner: Codable {
    let displayName: String
    let externalUrls: ExternalUrlsStruct
    let href: String
    let id: String
    let type: OwnerType
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case externalUrls = "external_urls"
        case href, id, type, uri
    }
}

enum OwnerType: String, Codable {
    case user = "user"
}

// MARK: - Tracks
struct TracksStruct: Codable {
    let href: String
    let total: Int
}

enum ItemType: String, Codable {
    case playlist = "playlist"
}
