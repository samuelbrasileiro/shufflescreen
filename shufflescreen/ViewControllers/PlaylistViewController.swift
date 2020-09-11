//
//  PlaylistViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

class PlaylistViewController: BaseViewController {
    
    var artistsSeeds: [String]?
    var tracksSeeds: [String]?
    
    var recommendedTracks: [Track] = []
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tracksTextView: UITextView!
    
    var hasCreated = (false,false){
        didSet{
            if hasCreated == (true,true){
                self.tracksTextView.text = (0..<self.recommendedTracks.count).map({"\($0 + 1): \(self.recommendedTracks[$0].name!)"}).joined(separator: "\n")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.view.addGestureRecognizer(gesture)
        nameTextField.text = ""
        nameTextField.placeholder = "Write your playlist name"
        
        artistsSeeds!.shuffle()        
        tracksSeeds!.shuffle()

        if tracksSeeds!.count == 0 || artistsSeeds!.count == 0{
            return
        }
        fetchRecommendations(artists: Array(artistsSeeds![0...2]), tracks: Array(tracksSeeds![0...1])){ result in
            if let recommendations = result as? Recommendations{
                self.recommendedTracks.append(contentsOf: recommendations.tracks!)
                
                self.hasCreated.0 = true
            }
        }
        fetchRecommendations(artists: Array(artistsSeeds![3...4]), tracks: Array(tracksSeeds![2...4])){ result in
            if let recommendations = result as? Recommendations{
                self.recommendedTracks.append(contentsOf: recommendations.tracks!)
                self.hasCreated.1 = true
            }
            
        }
    }
    @objc func tap(_ sender: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    func fetchRecommendations(artists: [String], tracks: [String], completion: @escaping (Any?) -> Void){
        if artists.count + tracks.count > 5{
            print("Overpassed limit of five seeds to recommend")
            return
        }
        let defaults = UserDefaults.standard
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spotify.com"
        components.path = "/v1/recommendations"
        let joinedArtists = artists.joined(separator: ",")
        let joinedTracks = tracks.joined(separator: ",")
        components.queryItems = [
            URLQueryItem(name: "limit", value: "30"),
            URLQueryItem(name: "seed_artists", value: joinedArtists),
            URLQueryItem(name: "seed_tracks", value: joinedTracks)
        ]
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessTokenKey)!, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                
                let recommendations = try JSONDecoder().decode(Recommendations.self, from: data)
                DispatchQueue.main.async {
                    completion(recommendations)
                }
            }
            catch {
                print(error)
                completion(nil)
            }
        }.resume()
    }
    
    @IBAction func createPlaylistButtonAction(_ sender: UIButton) {
        if hasCreated != (true,true){
            print("espera terminar de criar, po")
            return
        }
        
        fetchUser { user in
            guard let id = user?.id else { return }
            
            var text = "Shufflescreen Playlist"
            DispatchQueue.main.async {
                if self.nameTextField.text != ""{
                    text = self.nameTextField.text!
                }
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
    
    
    
    // MARK: - Network Requests
    
    func fetchUser(completion: @escaping (User?) -> Void) {
        let defaults = UserDefaults.standard
        let url = URL(string: "https://api.spotify.com/v1/me")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessTokenKey)!, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    completion(user)
                }
            } catch {
                print("error")
                completion(nil)
            }
        }.resume()
    }
    
    func createNewPlaylist(id: String, playlist: PlaylistInput, completion: @escaping (PlaylistOutput?) -> Void) {
        let defaults = UserDefaults.standard
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
        let defaults = UserDefaults.standard
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
