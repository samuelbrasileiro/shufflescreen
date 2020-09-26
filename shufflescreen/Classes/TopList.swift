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
    class func archive(tracks: [Track]){
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        
        let tracksData = try? JSONEncoder().encode(tracks)
        
        defaults.setValue(tracksData, forKey: Keys.kTopTracksList)
    }
    class func restore()->[Track]?{
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        guard let tracksData = defaults.data(forKey: Keys.kTopTracksList) else{
            print("could not fetch top tracks from UserDefaults")
            return nil
        }
        
        let tracks = try? JSONDecoder().decode([Track].self, from: tracksData)
        
        return tracks
    }
    class func fetch(timeRange: String, limit: String, completion: @escaping (Result<TopTracksList,Error>) -> Void){
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spotify.com"
        components.path = "/v1/me/top/tracks"
        components.queryItems = [
            URLQueryItem(name: "time_range", value: timeRange),
            URLQueryItem(name: "limit", value: limit)
        ]
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessTokenKey)!, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(.failure(error!))
                return
            }
            do {
                let topTracksList = try JSONDecoder().decode(TopTracksList.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(topTracksList))
                }
                
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
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
    
    class func archive(artists: [Artist]){
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        
        let artistsData = try? JSONEncoder().encode(artists)
        
        defaults.setValue(artistsData, forKey: Keys.kTopArtistsList)
    }
    class func restore()->[Artist]?{
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        guard let artistsData = defaults.data(forKey: Keys.kTopArtistsList) else{
            print("could not fetch top artists from UserDefaults")
            return nil
        }
        
        let artists = try? JSONDecoder().decode([Artist].self, from: artistsData)
        
        return artists
    }
    
    class func fetch(timeRange: String, limit: String, completion: @escaping (Result<TopArtistsList,Error>) -> Void){
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spotify.com"
        components.path = "/v1/me/top/artists"
        components.queryItems = [
            URLQueryItem(name: "time_range", value: timeRange),
            URLQueryItem(name: "limit", value: limit)
        ]
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessTokenKey)!, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(.failure(error!))
                return
            }
            do {
                let topArtistsList = try JSONDecoder().decode(TopArtistsList.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(topArtistsList))
                }
                
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }
    
}
