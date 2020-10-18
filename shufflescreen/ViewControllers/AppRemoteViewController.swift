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
    
    var nowPlayingBank: NowPlayingBank?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        nowPlayingBank = NowPlayingBank(nowPlaying: NowPlaying.restore()!)
        self.child?.view.backgroundColor = .clear

        self.shuffleButton.backgroundColor = self.nowPlayingBank?.nowPlaying.imageColors.detail
        self.shuffleButton.setTitleColor(self.nowPlayingBank?.nowPlaying.imageColors.background, for: .normal)
        self.view.backgroundColor = self.nowPlayingBank?.nowPlaying.imageColors.background

        child = UIHostingController(rootView: NowPlayingView(bank: nowPlayingBank!))
        child!.view.backgroundColor = .clear
        child!.view.translatesAutoresizingMaskIntoConstraints = false
//        child!.view.frame = CGRect(x: self.view.bounds.midX - 150, y: self.view.bounds.midY - 300, width: 300, height: 500)
        print(child!.view.frame)
        self.view.addSubview(child!.view)
        self.addChild(child!)
        self.view.sendSubviewToBack(child!.view)
        
        let constraints = [
            child!.view.topAnchor.constraint(equalTo: self.connectToAppRemoteButton.bottomAnchor, constant: 20),
            child!.view.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
            child!.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 60),
            child!.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -60),
            child!.view.bottomAnchor.constraint(lessThanOrEqualTo: self.shuffleButton.topAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(constraints)
        
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
        if isSpotifyNotInstalled(){
            return
        }

        connectionIndicatorView.state = .connecting
        
        
        appRemote.authorizeAndPlayURI("")
        appRemote.connect()
    }
    
    @objc func isSpotifyNotInstalled()->Bool{
            
        if !UIApplication.shared.canOpenURL(URL(string: "spotify://")!){
            let alert = UIAlertController(title: "Download Spotify App", message: "To Continue, you need to download spotify app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true)
            return false
        }
        else{
            return true
        }
        
    }
    @IBAction func shuffleSongButton(_ sender: UIButton) {
        
        if isSpotifyNotInstalled(){
            return
        }
        
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
            
            if self.nowPlayingBank?.nowPlaying.trackName != playerState.track.name{
                
                let trackID = String(trackURI.split(separator: ":").last!)
                
                Track.fetch(trackID: trackID){ result in
                    if case .success(let track) = result {
                        let initialNP = NowPlaying(trackName: track.name!, artist: track.artists![0].name!, date: track.album!.releaseDate!, image: self.nowPlayingBank?.nowPlaying.image, imageColors: (self.nowPlayingBank?.nowPlaying.imageColors)!)
                        
                        self.nowPlayingBank?.nowPlaying = initialNP
                        if let images = track.album!.images{
                            
                            SPTImage.fetch(scale: 300, images: images){ result in
                                if case .success(let image) = result {
                                    let nowPlaying = NowPlaying(trackName: track.name!, artist: track.artists![0].name!, date: track.album!.releaseDate!, image: image, imageColors: image.getColors()!)
                                    
                                    NowPlaying.archive(nowPlaying: nowPlaying)
                                    
                                    self.nowPlayingBank?.nowPlaying = nowPlaying
                                    UIView.animate(withDuration: 2.0) {
                                        self.view.backgroundColor = self.nowPlayingBank?.nowPlaying.imageColors.background
                                        self.shuffleButton.backgroundColor = self.nowPlayingBank?.nowPlaying.imageColors.detail
                                        self.shuffleButton.setTitleColor(self.nowPlayingBank?.nowPlaying.imageColors.background, for: .normal)
                                        
                                        
                                    }
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
    class NowPlayingBank: ObservableObject{
        @Published var nowPlaying: NowPlaying
        init(nowPlaying: NowPlaying) {
            self.nowPlaying = nowPlaying
        }
    }
    struct NowPlayingView : View {
        @ObservedObject var bank: NowPlayingBank
        var body: some View {

            VStack(alignment: .leading, spacing: 4) {
                if let image = self.bank.nowPlaying.image{
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 240, height: 240, alignment: .center)
                        .padding()
                        .animation(.spring()
                        )
                }
                
                
                Text(self.bank.nowPlaying.trackName)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(self.bank.nowPlaying.imageColors.primary))
                    .bold()
                    .animation(.easeInOut(duration: 2))
                Text("by \(self.bank.nowPlaying.artist)")
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundColor(Color(self.bank.nowPlaying.imageColors.secondary))
                    .animation(.easeInOut(duration: 2))
                Text("Released: \(self.bank.nowPlaying.date) ")
                    .font(.system(.caption))
                    .foregroundColor(Color(self.bank.nowPlaying.imageColors.detail))
                    .animation(.easeInOut(duration: 2))
                
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            
            .background(Color.clear)
            
            
        }
        
        static func formatHour(date: Date) -> String {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
    }
}
