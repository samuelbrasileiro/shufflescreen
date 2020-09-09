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
        fetchTopTracks(){topTracksList in
            print(topTracksList!)
            print(topTracksList!.items!.count)
            
            var index = 1
            self.topTextView.text = ""
            
            for item in topTracksList!.items!{
                self.topTextView.text.append(contentsOf: "\(index): " + item.name! + "\n")
                index += 1
            }
        }
    }
    
    func fetchTopTracks(completion: @escaping (TopTracksList?) -> Void){
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
                let topTracksList = try JSONDecoder().decode(TopTracksList.self, from: data)
                //print(user.displayName ?? "nada")
                
                DispatchQueue.main.async {
                    completion(topTracksList)
                    //completion(recommendations)
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
    

}
