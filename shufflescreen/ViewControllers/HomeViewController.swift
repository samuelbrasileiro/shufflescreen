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
    
    @IBOutlet weak var currentSongStatusLabel: UILabel!
    @IBOutlet weak var currentSongLabel: UILabel!
    
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        User.fetch{ user in
            guard let user = user else{
                print("Could not fetch user.")
                return
            }
            self.displayNameLabel.text = "E aí, " + user.displayName!.split(separator: " ")[0] + "?"
            
            self.followersCountLabel.text = "Tas com " + String(user.followers!.total!) + " seguidores!"
        }
    }
    
}

