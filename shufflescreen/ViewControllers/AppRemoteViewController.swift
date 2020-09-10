//
//  AppRemoteViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 10/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

class AppRemoteViewController: BaseViewController {

    @IBOutlet weak var currentSongStatusLabel: UILabel!
    
    @IBOutlet weak var currentSongLabel: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var connectToAppRemoteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayerState), name: NSNotification.Name(rawValue: "updatePlayerState"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectedToAppRemote), name: NSNotification.Name(rawValue: "connectedToAppRemote"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectedFromAppRemote), name: NSNotification.Name(rawValue: "disconnectedFromAppRemote"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(couldNotConnectToAppRemote), name: NSNotification.Name(rawValue: "couldNotConnectToAppRemote"), object: nil)
        
        if appRemote.isConnected{
            updatePlayerState()
            warningLabel.isHidden = true
            connectToAppRemoteButton.isHidden = true
        }
        else{
            currentSongStatusLabel.isHidden = true
            currentSongLabel.isHidden = true
            
        }
        
        
    }
    @IBAction func connectToAppRemote(_ sender: UIButton) {
        appRemote.authorizeAndPlayURI("")
        appRemote.connect()
    }
    
    @objc func updatePlayerState(){
        appRemote.playerAPI?.getPlayerState(){ result, error in
            guard let playerState = result as? SPTAppRemotePlayerState else{
                print("Could not catch PlayerState")
                return
            }
            if playerState.isPaused{
                self.currentSongStatusLabel?.text = "Currently paused:"
            }
            else{
                self.currentSongStatusLabel?.text = "Currently playing:"
            }
            self.currentSongLabel?.text = playerState.track.name
        }
    }
    @objc func connectedToAppRemote(){
        warningLabel.isHidden = true
        connectToAppRemoteButton.isHidden = true
        currentSongStatusLabel.isHidden = false
        currentSongLabel.isHidden = false
    }
    
    @objc func disconnectedFromAppRemote(){
        //warningLabel.isHidden = false
        //connectToAppRemoteButton.isHidden = false
    }
    
    @objc func couldNotConnectToAppRemote(){
        warningLabel.isHidden = false
        connectToAppRemoteButton.isHidden = false
        currentSongStatusLabel.isHidden = true
        currentSongLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nc = self.navigationController as? BaseNavigationController{
            nc.appRemoteButton.isHidden = true
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent{
            if let nc = parent as? BaseNavigationController{
                nc.appRemoteButton.isHidden = false
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}