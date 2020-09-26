//
//  AlbumImageWidget.swift
//  AlbumImageWidget
//
//  Created by Samuel Brasileiro on 25/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import WidgetKit
import SwiftUI
import CoreData


struct AlbumImageWidgetView : View {
    var entry: LastAlbumImageEntry
    
    var body: some View {
        
        
        Image(data: entry.image?.pngData())?
            .resizable()
            .animation(.easeInOut)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            
            
    }
    

}


var in_progress = false


var currentImage: UIImage? = LastAlbumImageEntry.restore()

var newRefreshDate: Date = Date()

var initialized: Bool = false

class AlbumImageTimelineProvider: TimelineProvider {
    
    typealias Entry = LastAlbumImageEntry
    
    func placeholder(in context: Context) -> LastAlbumImageEntry {
        let fakeImage = LastAlbumImageEntry.restore()!
        return LastAlbumImageEntry(date: Date(), image: fakeImage)
    }
    
    
    
    func getSnapshot(in context: Context, completion: @escaping (LastAlbumImageEntry) -> ()) {
        Player.fetch { result in

            var image: UIImage? = nil
            if case .success(let player) = result {

                let url = player.item!.album!.images![0].url!
                
                let imageData = try? Data(contentsOf: URL(string: url)!)
                
                image = UIImage(data: imageData!)
                
                LastAlbumImageEntry.archive(image: image)
                
            } else {
                image = LastAlbumImageEntry.restore()
            }
            
            let entry = LastAlbumImageEntry(date: Date(), image: image)

            completion(entry)
        }
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<LastAlbumImageEntry>) -> ()) {
        
        
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .second, value: 10, to: currentDate)!

        initialized = true
        newRefreshDate = refreshDate
        if !in_progress {
            in_progress = true
            Player.fetch { result in

                var image: UIImage? = nil
                
                if case .success(let player) = result {
                    print(player.item!.album!.images![0].height!)
                    let url = player.item!.album!.images![0].url!
                    
                    let imageData = try? Data(contentsOf: URL(string: url)!)
                    
                    image = UIImage(data: imageData!)
                    
                    LastAlbumImageEntry.archive(image: image)
                    
                } else {
                    image = LastAlbumImageEntry.restore()
                }
                
                let entry = LastAlbumImageEntry(date: currentDate, image: image)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                
                currentImage = image
                in_progress = false

                completion(timeline)
            }
        }
        else{
            //in_progress = false
            currentImage = LastAlbumImageEntry.restore()
            
            let entry = LastAlbumImageEntry(date: currentDate, image: currentImage)
            
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            
            completion(timeline)
        }
        
        
    }
}


struct LastAlbumImageEntry: TimelineEntry {
    public let date: Date
    public let image: UIImage?
    
    static func archive(image: UIImage?){
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        print("archived")
        defaults.setValue(image!.pngData(), forKey: Keys.kWidgetImage)
    }
    static func restore()->UIImage?{
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        
        var image: UIImage? = nil
        if let data = defaults.data(forKey: Keys.kWidgetImage){
            print("adobedabedo")
            image = UIImage(data: data)
        }
        
        return image
    }
}

@main
struct AlbumImageCheckerWidget: Widget {
    
    private let kind: String = "AlbumImageCheckerWidget"
    
    public var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: AlbumImageTimelineProvider()) { entry in
            AlbumImageWidgetView(entry: entry)
        }.supportedFamilies([.systemSmall, .systemLarge])
        .configurationDisplayName("Album image")
        .description("Shows what album your Spotify is playing - by Samuel")
    }
}
