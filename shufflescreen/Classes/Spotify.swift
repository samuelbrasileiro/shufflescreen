//
//  SPTConfiguration.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 07/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import Foundation

class Spotify{
    
    
    static let userDefaults = UserDefaults.standard
    
    static var spotifyCode: String{
        return userDefaults.object(forKey: "SpotifyCode") as! String
    }
    
//    static var session: SPTSession?{
//        
//        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
//            do{
//                let sessionData = sessionObj as! Data
//                let sessionDecoded = try NSKeyedUnarchiver.unarchivedObject(ofClass: SPTSession.self, from: sessionData)
//                 return sessionDecoded
//            }
//            catch{
//                print(error)
//            }
//        }
//        return nil
//    }
}
