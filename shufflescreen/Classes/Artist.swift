//
//  Artist.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import Foundation

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
