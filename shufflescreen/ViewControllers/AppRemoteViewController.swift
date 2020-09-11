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
    
    @IBOutlet weak var albumImageView: UIImageView!
    
    private var connectionIndicatorView = ConnectionStatusIndicatorView()
    
    
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
            print("App Remote is connected")
            
        }
        else{
            currentSongStatusLabel.isHidden = true
            currentSongLabel.isHidden = true
            albumImageView.isHidden = true
            print("App Remote is disconnected")
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: connectionIndicatorView)
        connectionIndicatorView.frame = CGRect(origin: CGPoint(), size: CGSize(width: 20,height: 20))
        
        
    }
    @IBAction func connectToAppRemote(_ sender: UIButton) {
        connectionIndicatorView.state = .connecting
        
        
        appRemote.authorizeAndPlayURI("")
        appRemote.connect()
    }
    @IBAction func shuffleSongButton(_ sender: UIButton) {

        TopTracksList.fetch(timeRange: "medium_term", limit: "5"){ topTracksList in
            
            guard let topTracksList = topTracksList else{ return}
            
            Recommendations.fetch(artists: [], tracks: topTracksList.items!.map({$0.id!}), genres: [], limit: "10"){ recommendations in
                guard let recommendations = recommendations else{ return}
                for track in recommendations.tracks!{
                    print(track.name ?? "")
                }
                let track = recommendations.tracks!.randomElement()
                if self.appRemote.isConnected{

                    self.appRemote.playerAPI!.play(track!.uri!, asRadio: true){ result, error in
                        if let error = error{
                            print(error)
                        }
                    }
                }
                else{
                    self.connectionIndicatorView.state = .connecting
                    self.appRemote.authorizeAndPlayURI(track!.uri!)
                    self.appRemote.connect()
                }
            }
        }
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
            
            let trackURI = playerState.track.uri
            if trackURI == ""{
                return
            }

            if self.currentSongLabel?.text != playerState.track.name{
                self.currentSongLabel?.text = playerState.track.name

                let trackID = String(trackURI.split(separator: ":").last!)
                
                Track.fetch(trackID: trackID){ track in
                    if let images = track!.album!.images{
                        Album.fetchAlbumImage(scale: 300, images: images){ image in
                            self.albumImageView.image = image
                        }
                    }
                }
            }
        }
    }
    
    @objc func connectedToAppRemote(){
        connectionIndicatorView.state = .connected
        warningLabel.isHidden = true
        connectToAppRemoteButton.isHidden = true
        currentSongStatusLabel.isHidden = false
        currentSongLabel.isHidden = false
        albumImageView.isHidden = false
    }
    
    @objc func disconnectedFromAppRemote(){
        connectionIndicatorView.state = .disconnected
        //warningLabel.isHidden = false
        //connectToAppRemoteButton.isHidden = false
    }
    
    @objc func couldNotConnectToAppRemote(){
        connectionIndicatorView.state = .disconnected
        warningLabel.isHidden = false
        connectToAppRemoteButton.isHidden = false
        currentSongStatusLabel.isHidden = true
        currentSongLabel.isHidden = true
        albumImageView.isHidden = true
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
    
    
}

class Fetch{
    
    
    
}
