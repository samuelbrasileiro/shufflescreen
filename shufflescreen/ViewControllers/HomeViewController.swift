//
//  MenuViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 08/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit
import CloudKit

class HomeViewController: BaseViewController {
    
    let publicDatabase = CKContainer(identifier: "iCloud.samuel.shufflescreen").publicCloudDatabase
    let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
    
    @IBOutlet weak var displayNameLabel: UILabel!
    
    @IBOutlet weak var followersCountLabel: UILabel!
    
    
    @IBOutlet weak var discoverTopsButton: UIButton!
    @IBOutlet weak var shufflePlaylistButton: UIButton!
    @IBOutlet weak var shuffleWithFriendsButton: UIButton!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        discoverTopsButton.setCornerRadius(10)
        shufflePlaylistButton.setCornerRadius(10)
        shuffleWithFriendsButton.setCornerRadius(10)
        if let user = User.restore(){
            self.user = user
            
            self.showDetails()
            
        }
        else{
            User.fetch{ result in
                if case .success(let user) = result {
                    print("adobabedobedo")
                    self.user = user
                    User.archive(user: user)
                    
                    self.showDetails()
                    
                    self.archiveCloudKit(user: user)
                }
            }
        }
    }
    
    
    func showDetails(){
        self.displayNameLabel.text = "E aí, " + user!.displayName!.split(separator: " ")[0] + "?"
        
        self.followersCountLabel.text = "Tas com " + String(user!.followers!.total!) + " seguidores!"
    }
    
    
    func archiveCloudKit(user: User){
        let record = CKRecord(recordType: "SPTUser")
        
        record.setValue(user.displayName, forKey: "name")
        record.setValue(user.id, forKey: "id")
        
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let code = String((0...4).map{ _ in letters.randomElement()! })
        record.setValue(code, forKey: "code")
        
        defaults.setValue(code, forKey: Keys.kICloudCode)
        defaults.setValue(Date(), forKey: Keys.kICloudModificationDate)
        defaults.setValue(record.recordID.recordName, forKey: Keys.kICloudRecordName)
        
        self.publicDatabase.save(record) { (savedRecord, error) in
            
            DispatchQueue.main.async {
                if error == nil {
                    print("uhullll")
                    ICloudTopItem.updateTops()
                } else {
                    print(error!)
                }
            }
        }
    }
    
}

