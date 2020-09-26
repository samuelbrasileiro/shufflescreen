//
//  NowPlayingWidget.swift
//  NowPlayingWidget
//
//  Created by Samuel Brasileiro on 23/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import WidgetKit
import SwiftUI
import CoreData


let defaultImageColors = UIImageColors(background: UIColor.black, primary: UIColor.white, secondary: UIColor.blue, detail: UIColor.purple)


struct NowPlayingWidgetView : View {
    var entry: LastNowPlayingEntry
    
    var body: some View {
        
        HStack(alignment: .center, spacing: nil){
            VStack(alignment: .leading, spacing: 4) {
                Text("Now Playing")
                    .font(.system(.title3))
                    .foregroundColor(Color(entry.NowPlaying.imageColors.primary))
                Text(entry.NowPlaying.trackName)
                    .font(.system(.subheadline))
                    .foregroundColor(Color(entry.NowPlaying.imageColors.primary))
                    .bold()
                Text("by \(entry.NowPlaying.artist)")
                    .font(.system(.caption))
                    .foregroundColor(Color(entry.NowPlaying.imageColors.primary))
                Text("Released: \(entry.NowPlaying.date) ")
                    .font(.system(.caption))
                    .foregroundColor(Color(entry.NowPlaying.imageColors.secondary))
                Text("Updated at \(Self.formatHour(date: entry.date))")
                    .font(.system(.caption2))
                    .foregroundColor(Color(entry.NowPlaying.imageColors.detail))
            }.frame(minWidth: 150, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            
            .background(Color(entry.NowPlaying.imageColors.background))
            .animation(.easeInOut)
            
            Spacer()
            Image(data: entry.NowPlaying.image?.pngData())?
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
                .animation(.easeInOut)
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(Color(entry.NowPlaying.imageColors.background))
    }

    static func formatHour(date: Date) -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

var in_progress = false

func getImageColors(data: Data?) -> UIImageColors {
    
    if let data = data {
        let colors = UIImage(data: data)!.getColors()
        
        return colors!
    }
    else {
        return defaultImageColors
    }
}

var currentNowPlaying: NowPlaying = NowPlaying.restore()!

var newRefreshDate: Date = Date()

var initialized: Bool = false

class NowPlayingTimelineProvider: TimelineProvider {
    
    typealias Entry = LastNowPlayingEntry
    
    func placeholder(in context: Context) -> LastNowPlayingEntry {
        let fakeNowPlaying = NowPlaying.restore()!
        return LastNowPlayingEntry(date: Date(), NowPlaying: fakeNowPlaying)
    }
    
    
    
    func getSnapshot(in context: Context, completion: @escaping (LastNowPlayingEntry) -> ()) {
        Player.fetch { result in

            let nowplaying: NowPlaying
            if case .success(let player) = result {

                let songName = player.item!.name!
                let artistName = player.item!.artists![0].name!
                let date = player.item!.album!.releaseDate!
                let url = player.item!.album!.images![0].url!
                
                let imageData = try? Data(contentsOf: URL(string: url)!)
                let image = UIImage(data: imageData!)

                let colors = getImageColors(data: imageData)

                nowplaying = NowPlaying(trackName: songName, artist: artistName, date: date, image: image, imageColors: colors)
                
                NowPlaying.archive(nowPlaying: nowplaying)
                
            } else {
                nowplaying = NowPlaying.restore()!
            }
            let entry = LastNowPlayingEntry(date: Date(), NowPlaying: nowplaying)

            completion(entry)
        }
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
                    
                    let imageData = try? Data(contentsOf: URL(string: url)!)
                    let image = UIImage(data: imageData!)
                    
                    let colors = getImageColors(data: imageData)

                    nowplaying = NowPlaying(trackName: songName, artist: artistName, date: date, image: image, imageColors: colors)
                    
                    NowPlaying.archive(nowPlaying: nowplaying)
                    
                } else {
                    nowplaying = NowPlaying.restore()!
                }
                let entry = LastNowPlayingEntry(date: currentDate, NowPlaying: nowplaying)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                
                currentNowPlaying = nowplaying
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
            NowPlayingWidgetView(entry: entry)
        }.supportedFamilies([.systemSmall,.systemMedium])
        .configurationDisplayName("Now Playing")
        .description("Shows what your spotify is playing - by Samuel")
    }
}

