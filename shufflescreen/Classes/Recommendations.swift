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

