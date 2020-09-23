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
    
    class func fetch(timeRange: String, limit: String, completion: @escaping (TopTracksList?) -> Void){
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
            guard let data = data else { return }
            do {
                let topTracksList = try JSONDecoder().decode(TopTracksList.self, from: data)
                DispatchQueue.main.async {
                    completion(topTracksList)
                }
                
            } catch let error {
                print(error)
                completion(nil)
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
    
    class func fetch(timeRange: String, limit: String, completion: @escaping (TopArtistsList?) -> Void){
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
            guard let data = data else { return }
            do {
                let topArtistsList = try JSONDecoder().decode(TopArtistsList.self, from: data)
                DispatchQueue.main.async {
                    completion(topArtistsList)
                }
                
            } catch let error {
                print(error)
                completion(nil)
            }
        }.resume()
    }
    
}
