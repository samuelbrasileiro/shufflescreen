//
//  Album.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Album
class Album: Codable {
    let albumType: String?
    let artists: [Artist]?
    let availableMarkets: [String]?
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let images: [AlbumImage]?
    let name, releaseDate, releaseDatePrecision: String?
    let totalTracks: Int?
    let type, uri: String?

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case totalTracks = "total_tracks"
        case type, uri
    }

    init(albumType: String?, artists: [Artist]?, availableMarkets: [String]?, externalUrls: ExternalUrls?, href: String?, id: String?, images: [AlbumImage]?, name: String?, releaseDate: String?, releaseDatePrecision: String?, totalTracks: Int?, type: String?, uri: String?) {
        self.albumType = albumType
        self.artists = artists
        self.availableMarkets = availableMarkets
        self.externalUrls = externalUrls
        self.href = href
        self.id = id
        self.images = images
        self.name = name
        self.releaseDate = releaseDate
        self.releaseDatePrecision = releaseDatePrecision
        self.totalTracks = totalTracks
        self.type = type
        self.uri = uri
    }
    
    class func fetchAlbumImage(scale: Int, images: [AlbumImage], completion: @escaping (Result<UIImage,Error>) -> Void){
        for image in images{
            if image.height == scale{
                
                let request = URLRequest(url: URL(string: image.url!)!)
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data else {
                        completion(.failure(error!))
                        return
                    }
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data){
                            completion(.success(image))
                        }
                    }
                }.resume()
            }
        }
    }
}
