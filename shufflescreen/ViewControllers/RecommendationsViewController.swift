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
    
    var queryType: String = "tracks"
    var queryTimeRange: String = "medium_term"
    var queryLimit: String = "30"
    var bank: TopItemsBank = .init()
    
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var timeRangeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var limitSegmentedControl: UISegmentedControl!
        
    var child: UIHostingController<RecommendationsCollectionView>?
    @IBOutlet weak var discoverButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light

        child = UIHostingController(rootView: RecommendationsCollectionView(bank: bank))
        child?.view.backgroundColor = .clear
        child?.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(child!.view)
        let constraints = [
            child!.view.topAnchor.constraint(equalTo: discoverButton.bottomAnchor, constant: 10),
            child!.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            child!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            child!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5),
            child!.view.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -15)
        ]

        NSLayoutConstraint.activate(constraints)
        
        discoverButton.setCornerRadius(10)
        
    }
    
    
    @IBAction func discoverButtonAction(_ sender: UIButton) {
        self.bank.clear()
        if queryType == "tracks"{
            TopTracksList.fetch(timeRange: queryTimeRange, limit: queryLimit){ result in
                if case .success(let topTracksList) = result {

                    for item in topTracksList.items!{
                        self.bank.addItem(track: item)
                        print("artists.append(Artist(name: \"\(item.name!)\", imageURL: \"\(item.album!.images![0].url!)\", uri: \"\(item.uri!)\"))")
                    }
                    //TopTracksList.archive(tracks: topTracksList.items!)

                }
            }
        }
        else if queryType == "artists"{
            TopArtistsList.fetch(timeRange: queryTimeRange, limit: queryLimit){ result in
                if case .success(let topArtistsList) = result {
                                        
                    for item in topArtistsList.items!{
                        self.bank.addItem(artist: item)
                    }
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
        
         @ObservedObject var bank: TopItemsBank
        
        
        var body: some View{
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach((0..<bank.items!.count), id: \.self){ index in
                        HStack(alignment: .center, spacing: 6){
                            Link(destination: URL(string: bank.items![index].uri!)!){
                            (bank.items![index].image == nil ?
                                Image("spotify") : Image(uiImage: bank.items![index].image!))
                                .resizable()
                                .frame(minWidth: 0, maxWidth: 40, minHeight: 0, maxHeight: 40, alignment: .leading)
                                .aspectRatio(contentMode: .fill)
                            
                            Text("\(index + 1). " + bank.items![index].name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color(.black))
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                            }
                        }
                        
                        
                    }
                    
                    
                }.background(Color(.systemOrange))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            }
        }
        
    }
    
}
