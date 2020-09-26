//
//  MenuViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 08/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var displayNameLabel: UILabel!
    
    @IBOutlet weak var followersCountLabel: UILabel!
    
    
    @IBOutlet weak var discoverTopsButton: UIButton!
    @IBOutlet weak var shufflePlaylistButton: UIButton!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        discoverTopsButton.setCornerRadius(10)
        shufflePlaylistButton.setCornerRadius(10)
        
        if let user = User.restore(){
            self.user = user
            
            self.showDetails()
        }
        else{
            User.fetch{ result in
                if case .success(let user) = result {
                    
                    self.user = user
                    User.archive(user: user)
                    
                    self.showDetails()
                }
            }
        }
    }
    
    func showDetails(){
        self.displayNameLabel.text = "E aí, " + user!.displayName!.split(separator: " ")[0] + "?"
        
        self.followersCountLabel.text = "Tas com " + String(user!.followers!.total!) + " seguidores!"
    }
    
    @IBAction func createPlaylistButton(_ sender: Any) {
        
        var topTracksIDs: [String] = []
        var topArtistsIDs: [String] = []
        
        TopTracksList.fetch(timeRange: "medium_term", limit: "10"){result in
            
            if case .success(let topTracksList) = result {
                
                topTracksIDs = topTracksList.items!.map({$0.id!})
                
                TopArtistsList.fetch(timeRange: "medium_term", limit: "10"){result in
                    if case .success(let topArtistsList) = result {
                        
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
    }
    
}

