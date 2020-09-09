//
//  User.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 08/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import Foundation

// MARK: - User
class User: Codable {
    let country, displayName, email: String?
    let externalUrls: ExternalUrls?
    let followers: Followers?
    let href: String?
    let id: String?
    let images: [Image]?
    let product, type, uri: String?

    enum CodingKeys: String, CodingKey {
        case country
        case displayName = "display_name"
        case email
        case externalUrls = "external_urls"
        case followers, href, id, images, product, type, uri
    }

    init(country: String?, displayName: String?, email: String?, externalUrls: ExternalUrls?, followers: Followers?, href: String?, id: String?, images: [Image]?, product: String?, type: String?, uri: String?) {
        self.country = country
        self.displayName = displayName
        self.email = email
        self.externalUrls = externalUrls
        self.followers = followers
        self.href = href
        self.id = id
        self.images = images
        self.product = product
        self.type = type
        self.uri = uri
    }
}

