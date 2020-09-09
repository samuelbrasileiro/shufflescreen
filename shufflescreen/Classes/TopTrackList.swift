//
//  TopTrackList.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import Foundation

class TopTracksList: Codable {
    let items: [Track]?
    let total, limit, offset: Int?
    let href: String?
    let previous: String?
    let next: String?

    init(items: [Track]?, total: Int?, limit: Int?, offset: Int?, href: String?, previous: String?, next: String?) {
        self.items = items
        self.total = total
        self.limit = limit
        self.offset = offset
        self.href = href
        self.previous = previous
        self.next = next
    }
}

class TopArtistsList: Codable {
    let items: [Artist]?
    let total, limit, offset: Int?
    let href: String?
    let previous: String?
    let next: String?

    init(items: [Artist]?, total: Int?, limit: Int?, offset: Int?, href: String?, previous: String?, next: String?) {
        self.items = items
        self.total = total
        self.limit = limit
        self.offset = offset
        self.href = href
        self.previous = previous
        self.next = next
    }
}
