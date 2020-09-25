//
//  songWidget.swift
//  songWidget
//
//  Created by Samuel Brasileiro on 23/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import WidgetKit
import SwiftUI
import CoreData


let defaultImageColors = UIImageColors(background: UIColor.black, primary: UIColor.white, secondary: UIColor.blue, detail: UIColor.purple)


struct NowPlayingCheckerWidgetView : View {
    var entry: LastNowPlayingEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Now Playing")
                .font(.system(.title3))
                .foregroundColor(Color(entry.NowPlaying.imageColors.primary))
            Text(entry.NowPlaying.message)
                .font(.system(.subheadline))
                .foregroundColor(Color(entry.NowPlaying.imageColors.primary))
                .bold()
            Text("by \(entry.NowPlaying.author)")
                .font(.system(.caption))
                .foregroundColor(Color(entry.NowPlaying.imageColors.primary))
            Text("Released: \(entry.NowPlaying.date) ")
                .font(.system(.caption))
                .foregroundColor(Color(entry.NowPlaying.imageColors.secondary))
            Text("Updated at \(Self.formatHour(date: entry.date))")
                .font(.system(.caption2))
                .foregroundColor(Color(entry.NowPlaying.imageColors.detail))
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(Color(entry.NowPlaying.imageColors.background))
        .animation(.easeInOut)
        
    }

    static func formatHour(date: Date) -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct NowPlaying {
    
    let message: String
    let author: String
    let date: String
    let imageColors: UIImageColors
    
    
    static func archive(nowPlaying: NowPlaying){
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        
        defaults.setValue(nowPlaying.message, forKey: Keys.kWidgetMessage)
        defaults.setValue(nowPlaying.author, forKey: Keys.kWidgetAuthor)
        defaults.setValue(nowPlaying.date, forKey: Keys.kWidgetDate)
        
        defaults.setValue(nowPlaying.imageColors.background.toHex(), forKey: Keys.kWidgetImageColorBackground)
        defaults.setValue(nowPlaying.imageColors.primary.toHex(), forKey: Keys.kWidgetImageColorPrimary)
        defaults.setValue(nowPlaying.imageColors.secondary.toHex(), forKey: Keys.kWidgetImageColorSecondary)
        defaults.setValue(nowPlaying.imageColors.detail.toHex(), forKey: Keys.kWidgetImageColorDetail)
        
    }
    static func restore()->NowPlaying?{
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        
        let message = defaults.string(forKey: Keys.kWidgetMessage) ?? "Leãozinho"
        let author = defaults.string(forKey: Keys.kWidgetAuthor) ?? "Caetano Veloso"
        let date = defaults.string(forKey: Keys.kWidgetDate) ?? "2020-08-23"
        
        let background = defaults.string(forKey: Keys.kWidgetImageColorBackground) ?? UIColor.black.toHex()
        let primary = defaults.string(forKey: Keys.kWidgetImageColorPrimary) ?? UIColor.white.toHex()
        let secondary = defaults.string(forKey: Keys.kWidgetImageColorSecondary) ?? UIColor.blue.toHex()
        let detail = defaults.string(forKey: Keys.kWidgetImageColorDetail) ?? UIColor.purple.toHex()

        let imageColors = UIImageColors(background: UIColor(hex: background)!, primary: UIColor(hex: primary)!, secondary: UIColor(hex: secondary)!, detail: UIColor(hex: detail)!)
        
        return NowPlaying(message: message, author: author, date: date, imageColors: imageColors)
    }
}

var in_progress = false

var recent_NowPlaying: NowPlaying = NowPlaying(message: "Song", author: "Artist", date: "2020-09-23", imageColors: defaultImageColors)

func getImageColors(url: URL) -> UIImageColors {
    let imageData = try? Data(contentsOf: url)
    
    if(imageData != nil) {
        let colors = UIImage(data: imageData!)!.getColors()
        
        return colors!
    }
    else {
        return defaultImageColors
    }
}

var currentNowPlaying: NowPlaying = NowPlaying(message: "Song", author: "Artist", date: "2020-09-23", imageColors: defaultImageColors)
var newRefreshDate: Date = Date()

var initialized: Bool = false

class NowPlayingTimelineProvider: TimelineProvider {
    
    typealias Entry = LastNowPlayingEntry
    
    func placeholder(in context: Context) -> LastNowPlayingEntry {
        let fakeNowPlaying = NowPlaying(message: "Leãozinho", author: "Caetano Veloso", date: "2020-09-23", imageColors: defaultImageColors)
        return LastNowPlayingEntry(date: Date(), NowPlaying: fakeNowPlaying)
    }
    
    
    
    func getSnapshot(in context: Context, completion: @escaping (LastNowPlayingEntry) -> ()) {
        let fakeNowPlaying = NowPlaying(message: "Leãozinho", author: "Caetano Veloso", date: "2020-09-23", imageColors: defaultImageColors)
        let entry = LastNowPlayingEntry(date: Date(), NowPlaying: fakeNowPlaying)
        completion(entry)
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<LastNowPlayingEntry>) -> ()) {
        
        
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!

        initialized = true
        newRefreshDate = refreshDate
        if !in_progress {
            in_progress = true
            Player.fetch { result in

                let nowplaying: NowPlaying
                if case .success(let player) = result {

                    let songName = player.item!.name!
                    let artistName = player.item!.artists![0].name!
                    let date = player.item!.album!.releaseDate!
                    let url = player.item!.album!.images![0].url!
                    
                    let colors = getImageColors(url: URL(string: url)!)

                    nowplaying = NowPlaying(message: songName, author: artistName, date: date, imageColors: colors)
                    
                    NowPlaying.archive(nowPlaying: nowplaying)
                    
                } else {
                    nowplaying = NowPlaying.restore()!
                }
                let entry = LastNowPlayingEntry(date: currentDate, NowPlaying: nowplaying)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                
                currentNowPlaying = nowplaying
                recent_NowPlaying = nowplaying
                in_progress = false

                completion(timeline)
            }
        }
        else{
            //in_progress = false
            currentNowPlaying = NowPlaying.restore()!
            
            let entry = LastNowPlayingEntry(date: currentDate, NowPlaying: currentNowPlaying)
            
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            
            completion(timeline)
        }
        
        
    }
}


struct LastNowPlayingEntry: TimelineEntry {
    public let date: Date
    public let NowPlaying: NowPlaying
}

@main
struct NowPlayingCheckerWidget: Widget {
    
    private let kind: String = "NowPlayingCheckerWidget"
    
    public var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: NowPlayingTimelineProvider()) { entry in
            NowPlayingCheckerWidgetView(entry: entry)
        }
        .configurationDisplayName("Show what you're playing")
        .description("Shows what your spotify is playing!")
    }
}

