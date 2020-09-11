//
//  RecommendationsViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

class RecommendationsViewController: BaseViewController {
    
    var queryType: String = "tracks"
    var queryTimeRange: String = "medium_term"
    var queryLimit: String = "30"
    
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var timeRangeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var limitSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var topTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    
    @IBAction func discoverButtonAction(_ sender: UIButton) {
        if queryType == "tracks"{
            TopTracksList.fetch(timeRange: queryTimeRange, limit: queryLimit){ topTracksList in
                guard let topTracksList = topTracksList else {return}
                var index = 0
                self.topTextView.text = ""
                
                for item in topTracksList.items!{
                    index += 1
                    self.topTextView.text.append(contentsOf: "\(index): " + item.name! + "\n")
                }
            }
        }
           
        else if queryType == "artists"{
            TopArtistsList.fetch(timeRange: queryTimeRange, limit: queryLimit){ topArtistsList in
                guard let topArtistsList = topArtistsList else {return}
                
                var index = 0
                self.topTextView.text = ""
                
                for item in topArtistsList.items!{
                    index += 1
                    self.topTextView.text.append(contentsOf: "\(index): " + item.name! + "\n")
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
    
    @IBAction func createPlaylistButton(_ sender: Any) {
        
        var topTracksIDs: [String] = []
        var topArtistsIDs: [String] = []
        
        TopTracksList.fetch(timeRange: "medium_term", limit: "10"){result in
            guard let topTracksList = result else{return}
            
            topTracksIDs = topTracksList.items!.map({$0.id!})
            
            TopArtistsList.fetch(timeRange: "medium_term", limit: "10"){result in
                guard let topArtistsList = result else {return}
                
                topArtistsIDs = topArtistsList.items!.map({$0.id!})
                
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlaylistViewController") as? PlaylistViewController{
                    vc.artistsSeeds = topArtistsIDs
                    vc.tracksSeeds = topTracksIDs
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
