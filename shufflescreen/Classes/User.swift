//
//  User.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 08/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import Foundation

// MARK: - User
class User: Codable {
    let country, displayName, email: String?
    let externalUrls: ExternalUrls?
    let followers: Followers?
    let href: String?
    let id: String?
    let images: [AlbumImage]?
    let product, type, uri: String?

    enum CodingKeys: String, CodingKey {
        case country
        case displayName = "display_name"
        case email
        case externalUrls = "external_urls"
        case followers, href, id, images, product, type, uri
    }

    init(country: String?, displayName: String?, email: String?, externalUrls: ExternalUrls?, followers: Followers?, href: String?, id: String?, images: [AlbumImage]?, product: String?, type: String?, uri: String?) {
        self.country = country
        self.displayName = displayName
        self.email = email
        self.externalUrls = externalUrls
        self.followers = followers
        self.href = href
        self.id = id
        self.images = images
        self.product = product
        self.type = type
        self.uri = uri
    }
    class func archive(user: User){
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        
        let userData = try? JSONEncoder().encode(user)
        
        defaults.setValue(userData, forKey: Keys.kUser)
    }
    
    class func restore()->User?{
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        
        guard let userData = defaults.data(forKey: Keys.kUser) else{
            print("could not fetch user from UserDefaults")
            return nil
        }
        
        let user = try? JSONDecoder().decode(User.self, from: userData)
        
        return user
    }
    
    class func fetch(completion: @escaping (Result<User,Error>) -> Void) {
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        let url = URL(string: "https://api.spotify.com/v1/me")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessTokenKey)!, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(.failure(error!))
                return
            }
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(user))
                }
            } catch {
                print("error")
                completion(.failure(error))
            }
        }.resume()
    }
    
}

