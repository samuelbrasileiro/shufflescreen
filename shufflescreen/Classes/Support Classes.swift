//
//  Support.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

// MARK: - Image
class SPTImage: Codable {
    let height: Int?
    let url: String?
    let width: Int?

    init(height: Int?, url: String?, width: Int?) {
        self.height = height
        self.url = url
        self.width = width
    }
    
    class func fetch(scale: Int, images: [SPTImage], completion: @escaping (Result<UIImage,Error>) -> Void){
        var image: SPTImage
        if let i = images.firstIndex(where: {$0.height == scale}){
            image = images[i]
        }
        else{
            let sortedImages = images.sorted{$0.height! < $1.height!}
            image = sortedImages[0]
        }

        let request = URLRequest(url: URL(string: image.url!)!)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(.failure(error!))
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data){
                    completion(.success(image))
                    return
                }
            }
        }.resume()
        
    }
}

// MARK: - Followers
class Followers: Codable {
    let href: String?
    let total: Int?

    init(href: String?, total: Int?) {
        self.href = href
        self.total = total
    }
}

// MARK: - ExternalIDS
class ExternalIDS: Codable {
    let isrc: String?

    init(isrc: String?) {
        self.isrc = isrc
    }
}

// MARK: - ExternalUrls
class ExternalUrls: Codable {
    let spotify: String?

    init(spotify: String?) {
        self.spotify = spotify
    }
}

struct PlaylistInput: Codable {
    var name: String
    var description: String = "Playlist criada baseado no seu gosto por Samuel :)"
    var isPublic: Bool = true
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case isPublic = "public"
    }
}

struct PlaylistOutput: Codable {
    var id: String
}
