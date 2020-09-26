//
//  NowPlaying.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 25/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

struct NowPlaying {
    
    let trackName: String
    let artist: String
    let date: String
    let image: UIImage?
    let imageColors: UIImageColors
    
    static func archive(nowPlaying: NowPlaying){
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        
        defaults.setValue(nowPlaying.trackName, forKey: Keys.kWidgetTrackName)
        defaults.setValue(nowPlaying.artist, forKey: Keys.kWidgetArtist)
        defaults.setValue(nowPlaying.date, forKey: Keys.kWidgetDate)
        
        defaults.setValue(nowPlaying.imageColors.background.toHex(), forKey: Keys.kWidgetImageColorBackground)
        defaults.setValue(nowPlaying.imageColors.primary.toHex(), forKey: Keys.kWidgetImageColorPrimary)
        defaults.setValue(nowPlaying.imageColors.secondary.toHex(), forKey: Keys.kWidgetImageColorSecondary)
        defaults.setValue(nowPlaying.imageColors.detail.toHex(), forKey: Keys.kWidgetImageColorDetail)
        
        defaults.setValue(nowPlaying.image?.pngData(), forKey: Keys.kWidgetImage)
    }
    static func restore()->NowPlaying?{
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        
        let message = defaults.string(forKey: Keys.kWidgetTrackName) ?? "Mystery of Love"
        let author = defaults.string(forKey: Keys.kWidgetArtist) ?? "Sufjan Stevens"
        let date = defaults.string(forKey: Keys.kWidgetDate) ?? "2017-12-01"
        
        let background = defaults.string(forKey: Keys.kWidgetImageColorBackground) ?? "#2e609d"
        let primary = defaults.string(forKey: Keys.kWidgetImageColorPrimary) ?? "#f6e91f"
        let secondary = defaults.string(forKey: Keys.kWidgetImageColorSecondary) ?? "#b0ad77"
        let detail = defaults.string(forKey: Keys.kWidgetImageColorDetail) ?? "#b4a41f"
        var image: UIImage? = nil
        if let data = defaults.data(forKey: Keys.kWidgetImage){
            print("adobedabedo")
            image = UIImage(data: data)
        }
        
        let imageColors = UIImageColors(background: UIColor(hex: background)!, primary: UIColor(hex: primary)!, secondary: UIColor(hex: secondary)!, detail: UIColor(hex: detail)!)
        
        return NowPlaying(trackName: message, artist: author, date: date, image: image, imageColors: imageColors)
    }
}
