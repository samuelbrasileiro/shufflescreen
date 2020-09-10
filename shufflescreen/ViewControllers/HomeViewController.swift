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
        
        fetchUser(){user in
            guard let user = user else{
                print("Could not fetch user.")
                return
            }
            self.displayNameLabel.text = "Hey, " + user.displayName! + "!"
            
            self.followersCountLabel.text = String(user.followers!.total!) + " followers, wow."
        }
    }
    
    func fetchUser(completion: @escaping (User?) -> Void){
        let defaults = UserDefaults.standard
        let url = URL(string: "https://api.spotify.com/v1/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer " + defaults.string(forKey: "access-token-key")!, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                print(user.displayName ?? "nada")
                
                DispatchQueue.main.async {
                    completion(user)
                }
                
                
            } catch let error {
                print(error)
                completion(nil)
            }
        }.resume()
    }
    
}

