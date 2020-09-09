//
//  Support.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import Foundation

// MARK: - Image
class Image: Codable {
    let height: Int?
    let url: String?
    let width: Int?

    init(height: Int?, url: String?, width: Int?) {
        self.height = height
        self.url = url
        self.width = width
    }
}

// MARK: - Followers
class Followers: Codable {
    let href: String?
    let total: Int?

    init(href: String?, total: Int?) {
        self.href = href
        self.total = total
    }
}

// MARK: - ExternalIDS
class ExternalIDS: Codable {
    let isrc: String?

    init(isrc: String?) {
        self.isrc = isrc
    }
}

// MARK: - ExternalUrls
class ExternalUrls: Codable {
    let spotify: String?

    init(spotify: String?) {
        self.spotify = spotify
    }
}
