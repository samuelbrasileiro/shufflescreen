//
//  AppRemoteViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 10/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit
import SwiftUI

class AppRemoteViewController: BaseViewController {
    

    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var connectToAppRemoteButton: UIButton!
    
    @IBOutlet weak var shuffleButton: UIButton!
    
    var nowPlayingView: NowPlayingView?
    var child: UIHostingController<NowPlayingView>?
    private var connectionIndicatorView = ConnectionStatusIndicatorView()
    
    var nowPlaying: NowPlaying?{
        didSet{
            self.nowPlayingView = NowPlayingView(nowPlaying: self.nowPlaying!)
            self.child?.view.backgroundColor = .clear
            self.child?.rootView = self.nowPlayingView!
            
            if oldValue == nil{ return}
            UIView.animate(withDuration: 2.0) {
                self.view.backgroundColor = self.nowPlaying!.imageColors.background
                self.shuffleButton.backgroundColor = self.nowPlaying!.imageColors.detail
                self.shuffleButton.setTitleColor(self.nowPlaying!.imageColors.background, for: .normal)
                
                
            }
            
            
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nowPlaying = NowPlaying.restore()
        nowPlayingView = NowPlayingView(nowPlaying: nowPlaying!)
        self.shuffleButton.backgroundColor = self.nowPlaying!.imageColors.detail
        self.shuffleButton.setTitleColor(self.nowPlaying!.imageColors.background, for: .normal)
        self.view.backgroundColor = self.nowPlaying!.imageColors.background

        child = UIHostingController(rootView: nowPlayingView!)
        child!.view.backgroundColor = .clear
        child!.view.translatesAutoresizingMaskIntoConstraints = false
        child!.view.frame = CGRect(x: self.view.bounds.midX - 150, y: self.view.bounds.midY - 300, width: 300, height: 500)
        self.view.addSubview(child!.view)
        
        
        self.addChild(child!)
        
        shuffleButton.setCornerRadius(10)
        
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
        
        TopTracksList.fetch(timeRange: "medium_term", limit: "5"){ result in
            
            if case .success(let topTracksList) = result {
                
                Recommendations.fetch(artists: [], tracks: topTracksList.items!.map({$0.id!}), genres: [], limit: "10"){ result in
                    if case .success(let recommendations) = result {
                        for track in recommendations.tracks!{
                            print(track.name ?? "")
                        }
                        let track = recommendations.tracks!.randomElement()
                        if self.appRemote.isConnected{
                            print(track!.uri!)
                            self.appRemote.playerAPI?.play(track!.uri!, asRadio: true){ result, error in
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
        }
    }
    
    @objc func updatePlayerState(){
        appRemote.playerAPI?.getPlayerState(){ result, error in
            guard let playerState = result as? SPTAppRemotePlayerState else{
                print("Could not catch PlayerState")
                return
            }
            
            let trackURI = playerState.track.uri
            if trackURI == ""{
                return
            }
            
            if self.nowPlaying!.trackName != playerState.track.name{
                
                let trackID = String(trackURI.split(separator: ":").last!)
                
                Track.fetch(trackID: trackID){ result in
                    if case .success(let track) = result {
                        if let images = track.album!.images{
                            
                            SPTImage.fetch(scale: 300, images: images){ result in
                                if case .success(let image) = result {
                                    let nowPlaying = NowPlaying(trackName: track.name!, artist: track.artists![0].name!, date: track.album!.releaseDate!, image: image, imageColors: image.getColors()!)
                                    
                                    NowPlaying.archive(nowPlaying: nowPlaying)
                                    
                                    self.nowPlaying = nowPlaying
                                    
                                }
                            }
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
    }
    
    @objc func disconnectedFromAppRemote(){
        connectionIndicatorView.state = .disconnected
    }
    
    @objc func couldNotConnectToAppRemote(){
        connectionIndicatorView.state = .disconnected
        warningLabel.isHidden = false
        connectToAppRemoteButton.isHidden = false
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
    
    struct NowPlayingView : View {
        var nowPlaying: NowPlaying
        var body: some View {
            
            
            VStack(alignment: .leading, spacing: 4) {
                
                    Image(data: self.nowPlaying.image?.pngData())!
                        .resizable()
                        .frame(width: 240, height: 240, alignment: .center)
                        .padding()
                        .animation(.easeInOut(duration: 2))
                    
                    
                Text(self.nowPlaying.trackName)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(self.nowPlaying.imageColors.primary))
                        .bold()
                        .animation(.easeInOut(duration: 2))
                Text("by \(self.nowPlaying.artist)")
                        .font(.system(size: 18, weight: .light, design: .rounded))
                        .foregroundColor(Color(self.nowPlaying.imageColors.secondary))
                        .animation(.easeInOut(duration: 2))
                    Text("Released: \(self.nowPlaying.date) ")
                        .font(.system(.caption))
                        .foregroundColor(Color(self.nowPlaying.imageColors.detail))
                        .animation(.easeInOut(duration: 2))
                    
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            
                
                
            
        }

        static func formatHour(date: Date) -> String {

            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
    }
}
