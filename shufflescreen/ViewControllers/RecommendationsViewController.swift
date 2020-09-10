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
        
        fetchTopTracks(){result in
            if let topTracksList = result as? TopTracksList{
                var index = 0
                self.topTextView.text = ""
                
                for item in topTracksList.items!{
                    index += 1
                    self.topTextView.text.append(contentsOf: "\(index): " + item.name! + "\n")
                }
                
            } else if let topArtistsList = result as? TopArtistsList{
                var index = 0
                self.topTextView.text = ""
                
                for item in topArtistsList.items!{
                    index += 1
                    self.topTextView.text.append(contentsOf: "\(index): " + item.name! + "\n")
                }
            }
            
            
        }
    }
    
    func fetchTopTracks(completion: @escaping (Any?) -> Void){
        let defaults = UserDefaults.standard
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spotify.com"
        components.path = "/v1/me/top/" + queryType
        components.queryItems = [
            URLQueryItem(name: "time_range", value: queryTimeRange),
            URLQueryItem(name: "limit", value: queryLimit)
        ]
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer " + defaults.string(forKey: "access-token-key")!, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                if self.queryType == "tracks"{
                    let topTracksList = try JSONDecoder().decode(TopTracksList.self, from: data)
                    DispatchQueue.main.async {
                        completion(topTracksList)
                    }
                }
                else{
                    let topArtistsList = try JSONDecoder().decode(TopArtistsList.self, from: data)
                    DispatchQueue.main.async {
                        completion(topArtistsList)
                    }
                }
                
                
                
            } catch let error {
                print(error)
                completion(nil)
            }
        }.resume()
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
        
        queryType = "tracks"
        queryTimeRange = "medium_term"
        queryLimit = "10"
        var topTracksIDs: [String] = []
        fetchTopTracks(){result in
            
            if let topTracksList = result as? TopTracksList{
                topTracksIDs = topTracksList.items!.map({$0.id!})
            }
            
            self.queryType = "artists"
            self.queryTimeRange = "medium_term"
            self.queryLimit = "10"
            var topArtistsIDs: [String] = []
            
            self.fetchTopTracks(){result in
                if let topArtistsList = result as? TopArtistsList{
                    topArtistsIDs = topArtistsList.items!.map({$0.id!})
                }
                
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlaylistViewController") as? PlaylistViewController{
                    vc.artistsSeeds = topArtistsIDs
                    vc.tracksSeeds = topTracksIDs
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
