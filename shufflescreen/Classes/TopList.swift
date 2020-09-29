//
//  TopTrackList.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit
import CloudKit

class TopItemsBank: ObservableObject{
    
    @Published var items: [TopItem]?
    init() {
        items = []
    }
    func clear(){
        items = []
    }
    func addItem(track: Track){
        let item = TopItem(name: track.name!, image: nil, uri: track.uri, id: track.id)
        self.items!.append(item)
        let index = self.items!.count - 1
        SPTImage.fetch(scale: 64, images: track.album!.images!){ result in
            if case .success(let image) = result{
                self.items![index] = TopItem(name: item.name, image: image, uri: item.uri, id: item.id)
                
            }
            else{
                print("eita po")
            }
        }
    }
    
    func addItem(artist: Artist){
        let item = TopItem(name: artist.name!, image: nil, uri: artist.uri, id: artist.id)
        self.items!.append(item)
        let index = self.items!.count - 1
        
       
        let sortedImages = artist.images!.sorted{$0.height! < $1.height!}
        let image = sortedImages[0]
        
        print("artists.append(Artist(name: \"\(artist.name!)\", imageURL: \"\(image.url!)\", uri: \"\(artist.uri!)\"))")
        
        SPTImage.fetch(scale: 64, images: artist.images!){ result in
            if case .success(let image) = result{
                self.items![index].image = image
                self.items![index] = TopItem(name: item.name, image: image, uri: item.uri, id: item.id)
            }
            else{
                print("eita po")
            }
        }
    }
    
}
class TopItem{
    var name: String
    var image: UIImage?
    var uri: String?
    var id: String?
    init(name: String, image: UIImage?, uri: String?, id: String?){
        self.name = name
        self.image = image
        self.uri = uri
        self.id = id
    }
}

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
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessToken)!, forHTTPHeaderField: "Authorization")
        
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
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessToken)!, forHTTPHeaderField: "Authorization")
        
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

class ICloudTopItem{
    static func updateTops(){
        let publicDatabase = CKContainer(identifier: "iCloud.samuel.shufflescreen").publicCloudDatabase
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        
        let recordName = defaults.string(forKey: Keys.kICloudRecordName)!
        let recordID = CKRecord.ID(recordName: recordName)
        
        TopTracksList.fetch(timeRange: "medium_term", limit: "50"){ result in
            if case .success(let topTracksList) = result{
                TopArtistsList.fetch(timeRange: "medium_term", limit: "50"){ result in
                    if case .success(let topArtistsList) = result{
                        
                        publicDatabase.fetch(withRecordID: recordID){ record, error in
                            
                            if let record = record, error == nil {
                                //update your record here
                                let tracksIDs = topTracksList.items!.map{$0.id}
                                let artistsIDs = topArtistsList.items!.map{$0.id}
                                
                                record.setValue(tracksIDs, forKey: "trackIDs")
                                record.setValue(artistsIDs, forKey: "artistsIDs")
                                
                                publicDatabase.save(record){ _, error in
                                    if error == nil{
                                        print("atualizou")
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        
    }
}
