//
//  UserTopsViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit
import SwiftUI

class UserTopsViewController: BaseViewController {
    
    struct TopItem{
        var name: String
        var image: UIImage?
    }
    
    
    var queryType: String = "tracks"
    var queryTimeRange: String = "medium_term"
    var queryLimit: String = "30"
    
    var topItems: [TopItem]?{
        didSet{
            if oldValue == nil{
                child = UIHostingController(rootView: RecommendationsCollectionView(items: topItems!))
                child?.view.backgroundColor = .clear
                child?.view.translatesAutoresizingMaskIntoConstraints = false
                child?.view.frame = CGRect(x: self.view.bounds.midX - 200, y: self.view.bounds.midY + 20, width: 400, height: 360)
                self.view.addSubview(child!.view)
            }
            else{
                child?.rootView = RecommendationsCollectionView(items: topItems!)
            }
        }
    }
    
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var timeRangeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var limitSegmentedControl: UISegmentedControl!
        
    var recommendationsView: RecommendationsCollectionView?
    var child: UIHostingController<RecommendationsCollectionView>?
    @IBOutlet weak var discoverButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        discoverButton.setCornerRadius(10)
        
    }
    
    
    @IBAction func discoverButtonAction(_ sender: UIButton) {
        if queryType == "tracks"{
            TopTracksList.fetch(timeRange: queryTimeRange, limit: queryLimit){ result in
                if case .success(let topTracksList) = result {

                    self.topItems = topTracksList.items!.map{TopItem(name: $0.name!, image: nil)}
                    //TopTracksList.archive(tracks: topTracksList.items!)

                }
            }
        }
        else if queryType == "artists"{
            TopArtistsList.fetch(timeRange: queryTimeRange, limit: queryLimit){ result in
                if case .success(let topArtistsList) = result {
                                        
                    self.topItems = topArtistsList.items!.map{TopItem(name: $0.name!, image: nil)}
                    //TopArtistsList.archive(artists: topArtistsList.items!)

                }
            }
        }
    }
    
    @IBAction func segmentedControlActions(_ sender: UISegmentedControl) {
        if sender == typeSegmentedControl{
            if sender.selectedSegmentIndex == 0{
                queryType = "tracks"
            }
            else{
                queryType = "artists"
            }
        }
        else if sender == timeRangeSegmentedControl{
            if sender.selectedSegmentIndex == 0{
                queryTimeRange = "short_term"
            }
            else if sender.selectedSegmentIndex == 1{
                queryTimeRange = "medium_term"
            }
            else{
                queryTimeRange = "long_term"
            }
        }
        else if sender == limitSegmentedControl{
            if sender.selectedSegmentIndex == 0{
                queryLimit = "10"
            }
            else if sender.selectedSegmentIndex == 1{
                queryLimit = "30"
            }
            else{
                queryLimit = "50"
            }
        }
    }
    
    struct RecommendationsCollectionView: View{
        var items: [TopItem]
        
        var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        
        var body: some View{
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 6) {
                    ForEach((0..<items.count), id: \.self) {
                        Text(items[$0].name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.black))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                        
                    }
                }.background(Color(.systemOrange))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                
            }
        }
    }
    
}
