//
//  Track.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import Foundation

// MARK: - Track

class Track: Codable {
    let album: Album?
    let artists: [Artist]?
    let availableMarkets: [String]?
    let discNumber, durationMS: Int?
    let explicit: Bool?
    let externalIDS: ExternalIDS?
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let isLocal: Bool?
    let name: String?
    let popularity: Int?
    let previewURL: String?
    let trackNumber: Int?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case album, artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMS = "duration_ms"
        case explicit
        case externalIDS = "external_ids"
        case externalUrls = "external_urls"
        case href, id
        case isLocal = "is_local"
        case name, popularity
        case previewURL = "preview_url"
        case trackNumber = "track_number"
        case uri
    }

    init(album: Album?, artists: [Artist]?, availableMarkets: [String]?, discNumber: Int?, durationMS: Int?, explicit: Bool?, externalIDS: ExternalIDS?, externalUrls: ExternalUrls?, href: String?, id: String?, isLocal: Bool?, name: String?, popularity: Int?, previewURL: String?, trackNumber: Int?, uri: String?) {
        self.album = album
        self.artists = artists
        self.availableMarkets = availableMarkets
        self.discNumber = discNumber
        self.durationMS = durationMS
        self.explicit = explicit
        self.externalIDS = externalIDS
        self.externalUrls = externalUrls
        self.href = href
        self.id = id
        self.isLocal = isLocal
        self.name = name
        self.popularity = popularity
        self.previewURL = previewURL
        self.trackNumber = trackNumber
        self.uri = uri
    }
    
    
    class func fetch(trackID: String, completion: @escaping (Track?) -> Void){
        let defaults = UserDefaults.standard
        let url = URL(string: "https://api.spotify.com/v1/tracks/" + trackID)!
        var request = URLRequest(url: url)
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessTokenKey)!, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let track = try JSONDecoder().decode(Track.self, from: data)
                
                DispatchQueue.main.async {
                    completion(track)
                }
                
                
            } catch let error {
                print(error)
                completion(nil)
            }
        }.resume()
    }
    
}


