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
        
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var createPlaylistButton: UIButton!
    @IBOutlet weak var generateButton: UIButton!
    
    @IBOutlet weak var justForYouLabel: UILabel!
    
    var child: UIHostingController<TracksCollectionView>?
    
    var bank: TopItemsBank = .init()

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
        nameTextField.overrideUserInterfaceStyle = .dark
        
        child = UIHostingController(rootView: TracksCollectionView(bank: bank))
        child?.view.backgroundColor = .clear
        child?.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(child!.view)
        
        let constraints = [
            child!.view.topAnchor.constraint(equalTo: justForYouLabel.bottomAnchor, constant: 10),
            child!.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            child!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            child!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5),
            child!.view.bottomAnchor.constraint(lessThanOrEqualTo: self.nameTextField.topAnchor, constant: -15)
        ]
        NSLayoutConstraint.activate(constraints)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    @objc func tap(_ sender: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        let bottomOfTextField = nameTextField.convert(nameTextField.bounds, to: self.view).maxY;
        let topOfKeyboard = self.view.frame.height - keyboardSize.height
        
        if bottomOfTextField > topOfKeyboard {
            self.view.frame.origin.y = 0 - keyboardSize.height/2
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
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
                
                for item in recommendations.tracks!{
                    self.bank.addItem(track: item)
                }
                
                self.hasCreated.0 = true
            }
        }
        Recommendations.fetch(artists: Array(artistsSeeds![3...4]), tracks: Array(tracksSeeds![2...4]), genres: [], limit: "30"){ result in
            if case .success(let recommendations) = result {
                
                for item in recommendations.tracks!{
                    self.bank.addItem(track: item)
                }
                
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
        @ObservedObject var bank: TopItemsBank
                
        var body: some View{
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach((0..<bank.items!.count), id: \.self){ index in
                        HStack(alignment: .center, spacing: 6){
                            Link(destination: URL(string: bank.items![index].uri!)!){
                                (bank.items![index].image == nil ?
                                    Image("spotify") : Image(uiImage: bank.items![index].image!))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(minWidth: 0, maxWidth: 40, minHeight: 0, maxHeight: 40, alignment: .leading)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.black, lineWidth: 2))
                                    .padding([.leading, .top], 4)
                                    
                                Text("\(index + 1). " + bank.items![index].name)
                                    .lineLimit(2)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(.black))
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                                    
                                
                            }
                            Spacer(minLength: 10)
                            Button(action: {
                                bank.items!.remove(at: index)
                            }){
                                
                                Image(systemName: "multiply.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(minWidth: 0, maxWidth: 20, minHeight: 0, maxHeight: 20, alignment: .leading)
                                    .foregroundColor(Color(.black))
                            }
                            Spacer(minLength: 10)
                        }
                        Divider()
                    }
                }.background(Color(.systemOrange))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            }
        }
    }
    
    
    // MARK: - Create Playlist Requests
    
    func createNewPlaylist(id: String, playlist: PlaylistInput, completion: @escaping (PlaylistOutput?) -> Void) {
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!

        let url = URL(string: "https://api.spotify.com/v1/users/\(id)/playlists")!
        var request = URLRequest(url: url)
        
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessToken)!, forHTTPHeaderField: "Authorization")
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
        
        let joinedTracksURIs = bank.items!.map({$0.uri!}).joined(separator: ",")
        components.queryItems = [URLQueryItem(name: "uris", value: joinedTracksURIs)]
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer " + defaults.string(forKey: Keys.kAccessToken)!, forHTTPHeaderField: "Authorization")
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
