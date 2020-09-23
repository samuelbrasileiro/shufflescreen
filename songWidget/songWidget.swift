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

class Keys{
    static let kAccessTokenKey = "access-token-key"
    static let kRefreshTokenKey = "refresh-token-key"
    static let kSessionKey = "session-key"
    static let kWidgetNowPlaying = "widget-now-playing"
}

let defaultImageColors = UIImageColors(background: UIColor.black, primary: UIColor.white, secondary: UIColor.blue, detail: UIColor.purple)


struct NowPlayingCheckerWidgetView : View {
    let entry: LastNowPlayingEntry

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
            Text("Released: \(entry.NowPlaying.date)")
                .font(.system(.caption))
                .foregroundColor(Color(entry.NowPlaying.imageColors.secondary))
            Text("Updated at \(Self.format(date:entry.date))")
                .font(.system(.caption2))
                .foregroundColor(Color(entry.NowPlaying.imageColors.detail))
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(Color(entry.NowPlaying.imageColors.background))
        .animation(.easeInOut)

    }

    static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

class NowPlaying: NSObject, NSCoding {
    
    let message: String
    let author: String
    let date: String
    let imageColors: UIImageColors
    
    init(message: String, author: String, date: String, imageColors: UIImageColors) {
        self.message = message
        self.author = author
        self.date = date
        self.imageColors = imageColors
    }
    
    required init(coder aDecoder: NSCoder) {
        message = aDecoder.decodeObject(forKey: "message") as! String
        author = aDecoder.decodeObject(forKey: "author") as! String
        date = aDecoder.decodeObject(forKey: "date") as! String
        imageColors = aDecoder.decodeObject(forKey: "imageColors") as! UIImageColors
        
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(message, forKey: "message")
        aCoder.encode(author, forKey: "author")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(imageColors, forKey: "imageColors")

    }
    
    class func archive(nowPlaying: NowPlaying){
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        do{
            //let nowPlayingData = try NSKeyedArchiver.
            let nowPlayingData = try NSKeyedArchiver.archivedData(withRootObject: nowPlaying, requiringSecureCoding: false)
            
            defaults.set(nowPlayingData, forKey: Keys.kWidgetNowPlaying)
            
        
        }
        catch{
            print("error archiving nowPlaying: \(error)")
        }
    }
    class func restore()->NowPlaying?{
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        guard let nowPlayingData = defaults.object(forKey: Keys.kSessionKey) as? Data else { return nil }
        do {
            let nowPlaying = try NSKeyedUnarchiver.unarchivedObject(ofClass: NowPlaying.self, from: nowPlayingData)
            return nowPlaying
        } catch {
            print("error unarchiving nowPlaying: \(error)")
            return nil
        }
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
    /* protocol methods implemented below! */
    
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
        let refreshDate = Calendar.current.date(byAdding: .second, value: 10, to: currentDate)!
        print(currentDate)
        print(refreshDate)
        if true {
            
            
            
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
                    do{
                        NowPlaying.archive(nowPlaying: nowplaying)
                    }
                } else {
                    nowplaying = NowPlaying.restore() ?? NowPlaying(message: "Leãozinho", author: "Caetano Veloso", date: "2020-09-23", imageColors: defaultImageColors)
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
                let entry = LastNowPlayingEntry(date: currentDate, NowPlaying: currentNowPlaying)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                
                completion(timeline)
            }
            
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
        .configurationDisplayName("Now Playing by Samuel")
        .description("Shows your Spotify's Now Playing!")
    }
}

