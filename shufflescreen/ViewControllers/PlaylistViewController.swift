//
//  PlaylistViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit
import SwiftUI

class PlaylistViewController: BaseViewController {
    
    var artistsSeeds: [String]?
    var tracksSeeds: [String]?
    
    var recommendedTracks: [Track] = []
    
    class TracksBank: ObservableObject{
        @Published var items: [TrackItem]?
        init() {
            items = []
        }
    }
    class TrackItem{
        var name: String
        var image: UIImage?
        init(name: String, image: UIImage?){
            self.name = name
            self.image = image
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var createPlaylistButton: UIButton!
    @IBOutlet weak var generateButton: UIButton!
    
    var child: UIHostingController<TracksCollectionView>?
    
    var bank: TracksBank = .init()

    var hasCreated = (false,false){
        didSet{
            print("enchante")
            if hasCreated == (true,true){
                
                
                
                
            }
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createPlaylistButton.setCornerRadius(10)
        self.generateButton.setCornerRadius(10)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.view.addGestureRecognizer(gesture)
        nameTextField.text = ""
        nameTextField.placeholder = "Write your playlist name"
        
        child = UIHostingController(rootView: TracksCollectionView(bank: bank))
        child?.view.backgroundColor = .clear
        child?.view.translatesAutoresizingMaskIntoConstraints = false
        child?.view.frame = CGRect(x: self.view.bounds.midX - 200, y: self.view.bounds.midY - 300, width: 400, height: 360)
        
        self.view.addSubview(child!.view)
        
        
    }
    @objc func tap(_ sender: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    @IBAction func generateButtonAction(_ sender: UIButton) {
        if hasCreated != (false,false) && hasCreated != (true,true){
            print("wait")
            return
        }
        self.artistsSeeds = []
        self.tracksSeeds = []
        self.bank.items = []
        
        TopTracksList.fetch(timeRange: "medium_term", limit: "10"){result in
            
            if case .success(let topTracksList) = result {
                
                self.tracksSeeds = topTracksList.items!.map({$0.id!})
                
                TopArtistsList.fetch(timeRange: "medium_term", limit: "10"){result in
                    if case .success(let topArtistsList) = result {
                        
                        self.artistsSeeds = topArtistsList.items!.map({$0.id!})
                        
                        self.generate()
                        
                    }
                }
            }
        }
    }
    
    func generate(){
        artistsSeeds!.shuffle()
        tracksSeeds!.shuffle()
        
        if tracksSeeds!.count == 0 || artistsSeeds!.count == 0{
            return
        }
        Recommendations.fetch(artists: Array(artistsSeeds![0...2]), tracks: Array(tracksSeeds![0...1]), genres: [], limit: "30"){ result in
            if case .success(let recommendations) = result {
                self.recommendedTracks.append(contentsOf: recommendations.tracks!)
                
                self.bank.items!.append(contentsOf:  recommendations.tracks!.map{TrackItem(name: $0.name!, image: nil)})
                
                self.hasCreated.0 = true
            }
        }
        Recommendations.fetch(artists: Array(artistsSeeds![3...4]), tracks: Array(tracksSeeds![2...4]), genres: [], limit: "30"){ result in
            if case .success(let recommendations) = result {
                self.recommendedTracks.append(contentsOf: recommendations.tracks!)
                
                self.bank.items!.append(contentsOf:  recommendations.tracks!.map{TrackItem(name: $0.name!, image: nil)})
                
                self.hasCreated.1 = true
            }
            
        }
    }
    
    @IBAction func createPlaylistButtonAction(_ sender: UIButton) {
        if hasCreated != (true,true){
            print("espera terminar de criar, po")
            let alert = UIAlertController(title: "Ei, pô", message: "Espera terminar de criar a playlist, beleza?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            
            self.present(alert, animated: true)
            return
        }
        hasCreated = (false,false)
        
        let user = User.restore()
        guard let id = user?.id else {
            print("error ao fetch da id")
            return
        }
        var text = "Shufflescreen Playlist"
        DispatchQueue.main.async {
            if self.nameTextField.text != ""{
                text = self.nameTextField.text!
            }
            
            let playlist = PlaylistInput(name: text)
            self.createNewPlaylist(id: id, playlist: playlist) { playlistOutput in
                guard let playlistid = playlistOutput?.id else { return }
                self.addSongs(id: playlistid) {
                    print("songs added")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Hey, we created your playlist \(text)!", message: "Would you like to open your playlist in the Spotify app?", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Open In App", style: .default, handler: { (action) in
                            let url = URL(string: "spotify:playlist:" + playlistid)!
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                            self.navigationController?.popToRootViewController(animated: true)
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    struct TracksCollectionView: View{
        @ObservedObject var bank: TracksBank
        
        var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        
        var body: some View{
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 6) {
                    ForEach((0..<bank.items!.count), id: \.self) {
                        Text("\($0 + 1). " + bank.items![$0].name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.black))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                        
                    }
                }.background(Color(.clear))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                
            }
        }
    }
    
    
    // MARK: - Create Playlist Requests
    
    func createNewPlaylist(id: String, playlist: PlaylistInput, completion: @escaping (PlaylistOutput?) -> Void) {
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!

        let url = URL(string: "https://api.spotify.com/v1/users/\(id)/playlists")!
        var request = URLRequest(url: url)
        
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessTokenKey)!, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        do {
            let data = try JSONEncoder().encode(playlist)
            request.httpBody = data
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let response = response as? HTTPURLResponse, let data = data else { return }
                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2##, but is \(response.statusCode)")
                    print("response = \(response)")
                    return
                }
                do {
                    let playlist = try JSONDecoder().decode(PlaylistOutput.self, from: data)
                    completion(playlist)
                } catch {
                    print("error decoding playlist id")
                    completion(nil)
                }
            }.resume()
        } catch {
            print("error encoding playlist")
            completion(nil)
        }
        
    }
    func addSongs(id: String, completion: @escaping () -> Void) {
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spotify.com"
        components.path = "/v1/playlists/\(id)/tracks"
        let joinedTracksURIs = recommendedTracks.map({$0.uri!}).joined(separator: ",")
        components.queryItems = [URLQueryItem(name: "uris", value: joinedTracksURIs)]
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessTokenKey)!, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else { return }
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            completion()
        }.resume()
    }
    
    
    
}
