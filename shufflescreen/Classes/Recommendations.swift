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
    
    class func fetch(artists: [String], tracks: [String], genres: [String], limit: String, completion: @escaping (Recommendations?) -> Void){
        if artists.count + tracks.count + genres.count > 5{
            print("Overpassed limit of five seeds to recommend")
            return
        }
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spotify.com"
        components.path = "/v1/recommendations"
        let joinedArtists = artists.joined(separator: ",")
        let joinedTracks = tracks.joined(separator: ",")
        let joinedGenres = genres.joined(separator: ",")
        components.queryItems = [
            URLQueryItem(name: "limit", value: limit),
            URLQueryItem(name: "seed_artists", value: joinedArtists),
            URLQueryItem(name: "seed_tracks", value: joinedTracks),
            URLQueryItem(name: "genre_tracks", value: joinedGenres)
        ]
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessTokenKey)!, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                
                let recommendations = try JSONDecoder().decode(Recommendations.self, from: data)
                DispatchQueue.main.async {
                    completion(recommendations)
                }
            }
            catch {
                print(error)
                completion(nil)
            }
        }.resume()
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

