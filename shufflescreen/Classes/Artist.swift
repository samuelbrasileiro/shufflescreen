//
//  Artist.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

// MARK: - Artist
class Artist: Codable {
    let externalUrls: ExternalUrls?
    let followers: Followers?
    let genres: [String]?
    let href: String?
    let id: String?
    let images: [SPTImage]?
    let name: String?
    let popularity: Int?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers, genres, href, id, images, name, popularity, uri
    }

    init(externalUrls: ExternalUrls?, followers: Followers?, genres: [String]?, href: String?, id: String?, images: [SPTImage]?, name: String?, popularity: Int?, uri: String?) {
        self.externalUrls = externalUrls
        self.followers = followers
        self.genres = genres
        self.href = href
        self.id = id
        self.images = images
        self.name = name
        self.popularity = popularity
        self.uri = uri
    }
    
}

