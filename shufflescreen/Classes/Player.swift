//
//  Player.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 23/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import Foundation

// MARK: - Player
class Player: Codable {
    let device: Device?
    let shuffleState: Bool?
    let repeatState: String?
    let timestamp: Int?
    let context: PlayerContext?
    let progressMS: Int?
    let item: Track?
    let currentlyPlayingType: String?
    let actions: Actions?
    let isPlaying: Bool?

    enum CodingKeys: String, CodingKey {
        case device
        case shuffleState = "shuffle_state"
        case repeatState = "repeat_state"
        case timestamp, context
        case progressMS = "progress_ms"
        case item
        case currentlyPlayingType = "currently_playing_type"
        case actions
        case isPlaying = "is_playing"
    }

    init(device: Device?, shuffleState: Bool?, repeatState: String?, timestamp: Int?, context: PlayerContext?, progressMS: Int?, item: Track?, currentlyPlayingType: String?, actions: Actions?, isPlaying: Bool?) {
        self.device = device
        self.shuffleState = shuffleState
        self.repeatState = repeatState
        self.timestamp = timestamp
        self.context = context
        self.progressMS = progressMS
        self.item = item
        self.currentlyPlayingType = currentlyPlayingType
        self.actions = actions
        self.isPlaying = isPlaying
    }
    
    class func fetch(completion: @escaping (Result<Player,Error>) -> Void){
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        let url = URL(string: "https://api.spotify.com/v1/me/player")!
        var request = URLRequest(url: url)
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessTokenKey)!, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(.failure(error!))
                return
            }
            do {
                let player = try JSONDecoder().decode(Player.self, from: data)
                print(data)
                DispatchQueue.main.async {
                    completion(.success(player))
                }
                
                
            } catch let error {
                print("ERROROROR + \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
}

// MARK: - Actions
class Actions: Codable {
    let disallows: Disallows?

    init(disallows: Disallows?) {
        self.disallows = disallows
    }
}

// MARK: - Disallows
class Disallows: Codable {
    let resuming: Bool?

    init(resuming: Bool?) {
        self.resuming = resuming
    }
}

// MARK: - Context
class PlayerContext: Codable {
    let externalUrls: ExternalUrls?
    let href: String?
    let type, uri: String?

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, type, uri
    }

    init(externalUrls: ExternalUrls?, href: String?, type: String?, uri: String?) {
        self.externalUrls = externalUrls
        self.href = href
        self.type = type
        self.uri = uri
    }
}

// MARK: - Device
class Device: Codable {
    let id: String?
    let isActive, isPrivateSession, isRestricted: Bool?
    let name, type: String?
    let volumePercent: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case isActive = "is_active"
        case isPrivateSession = "is_private_session"
        case isRestricted = "is_restricted"
        case name, type
        case volumePercent = "volume_percent"
    }

    init(id: String?, isActive: Bool?, isPrivateSession: Bool?, isRestricted: Bool?, name: String?, type: String?, volumePercent: Int?) {
        self.id = id
        self.isActive = isActive
        self.isPrivateSession = isPrivateSession
        self.isRestricted = isRestricted
        self.name = name
        self.type = type
        self.volumePercent = volumePercent
    }
}
