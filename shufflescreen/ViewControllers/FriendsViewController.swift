//
//  FriendsViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 29/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit
import CloudKit
import SwiftUI
import AudioToolbox

class FriendsViewController: BaseViewController{
    var child: UIHostingController<FriendsView>?
    var bank: FriendsBank = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        child = UIHostingController(rootView: FriendsView(bank: bank))
        child?.view.backgroundColor = .clear
        child?.view.translatesAutoresizingMaskIntoConstraints = true
        child?.overrideUserInterfaceStyle = .dark
        child?.view.frame = CGRect(x: self.view.bounds.midX - 200, y: 90, width: 400, height: self.view.bounds.height - 90 - 30)
        self.view.addSubview(child!.view)
    }
    
}
class FriendsBank: ObservableObject{
    let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
    
    let publicDatabase = CKContainer(identifier: "iCloud.samuel.shufflescreen").publicCloudDatabase
    
    var myRecord: CKRecord?
    
    var friendRecord: CKRecord?
    
    @Published var hasGenerated = false
    
    @Published var friendDoesNotExist = false
    
    @Published var didPostInSpotify = false
    
    @Published var items: [TopItem]?
    
    var playlistID: String?
    
    var myCode: String
    
    var hasCreated: (Bool,Bool) = (false,false){
        didSet{
            if hasCreated == (true,true){
                hasGenerated = true
            }
        }
    }
    
    @Published var friendCode: String = ""{
        didSet{
            if friendCode == ""{
                return
            }
            
            if friendCode.count > 5 && oldValue.count <= 5 {
                friendCode = oldValue
                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { return }
                return
            }
            if friendCode.last!.isLowercase{
                friendCode = friendCode.uppercased()
                
            }
        }
    }
    
    init(){
        self.myCode = defaults.string(forKey: Keys.kICloudCode)!
        items = []
    }
    
    func generatePlaylist(){
        //self.friendDoesNotExist = false
        
        if friendCode == myCode{
            self.friendDoesNotExist = true
            self.friendCode = ""
            return
        }
        fetchFriendByCode{ result in
            if let friendRecord = result{
                print("yuhuu")
                let myRecordName = self.defaults.string(forKey: Keys.kICloudRecordName)!
                self.publicDatabase.fetch(withRecordID: CKRecord.ID(recordName: myRecordName)){record, error in
                    if let error = error{
                        print(error)
                        return
                    }
                    self.friendRecord = friendRecord
                    self.myRecord = record
                    
                    print("baixo bixes")
                    
                    self.downloadTopItems()
                    
                }
                
            }
            else{
                self.friendDoesNotExist = true
                self.friendCode = ""
            }
        }
    }
    

    
    func downloadTopItems(){
        items = []
        
        let myArtistsIDs = self.myRecord!["artistsIDs"] as! [String]
        let myTracksIDs = self.myRecord!["trackIDs"] as! [String]
        
        let friendArtistsIDs = self.friendRecord!["artistsIDs"] as! [String]
        let friendTracksIDs = self.friendRecord!["trackIDs"] as! [String]
        
        let artistsSeeds = sortPriorizer(array1: myArtistsIDs, array2: friendArtistsIDs).shuffled()
        let tracksSeeds = sortPriorizer(array1: myTracksIDs, array2: friendTracksIDs).shuffled()
        
        self.hasCreated = (false,false)
        
        Recommendations.fetch(artists: Array(artistsSeeds[0...2]), tracks: Array(tracksSeeds[0...1]), genres: [], limit: "30"){ result in
            if case .success(let recommendations) = result {
                
                for item in recommendations.tracks!{
                    self.addItem(track: item)
                }
                
                self.hasCreated.0 = true
            }
        }
        Recommendations.fetch(artists: Array(artistsSeeds[3...4]), tracks: Array(tracksSeeds[2...4]), genres: [], limit: "30"){ result in
            if case .success(let recommendations) = result {
                
                for item in recommendations.tracks!{
                    self.addItem(track: item)
                }
                
                self.hasCreated.1 = true
            }
            
        }
    }
    
    func addItem(track: Track){
        let item = TopItem(name: track.name!, image: nil, uri: track.uri, id: track.id)
        self.items!.append(item)
        let index = self.items!.count - 1
        SPTImage.fetch(scale: 64, images: track.album!.images!){ result in
            if case .success(let image) = result{
                if index < self.items!.count{
                    self.items![index] = TopItem(name: item.name, image: image, uri: item.uri, id: item.id)
                }
            }
            else{
                print("eita po")
            }
        }
    }
    
    func sortPriorizer(array1: [String], array2: [String])->[String]{
        let interleaved = zip(array1, array2).flatMap { [$0, $1] }
        let interleavedWithPriority = (0 ..< interleaved.count).map{(interleaved[$0], $0, 1)}
        
        let normalized = interleavedWithPriority.reduce([String:(Int,Int)]()) {
            var dict = $0
            dict[$1.0] = (dict[$1.0] ?? (0,0))
            dict[$1.0]!.0 += $1.1/2
            dict[$1.0]!.1 += $1.2
            return dict
            }.map{$0}

        let ordered = normalized.sorted{
            if $0.value.1 == $1.value.1{
                return $0.value.0 < $1.value.0
            }
            else{
                return $0.value.1 > $1.value.1
            }
        }
        return [String](ordered.map{$0.key}[0..<5])
    }
    
    
    func fetchFriendByCode(_ completion: @escaping (CKRecord?) -> ()){
        
        let predicate = NSPredicate(format: "code == %@", friendCode)
        
        let query = CKQuery(recordType: "SPTUser", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: .default){results, error in
            DispatchQueue.main.async {
                
                if error != nil{
                    print("whoa! erro aq")
                    print(error!)
                    completion(nil)
                    return
                }
                
                if results != nil {
                    
                    print(results!.count)
                    if results?.count == 1 {
                        completion(results![0])
                    }
                    else{//anormalidade
                        
                    //    let sortedResults = results!.sorted{$0.modificationDate! < $1.modificationDate!}
                        completion(nil)
                    }
                }
                else{
                    print("puts, vaziozio")
                    completion(nil)
                }
            }
            
        }
        
    }
    func pushToSpotify(){
        
        let user = User.restore()
        guard let id = user?.id else {
            print("error ao fetch da id")
            return
        }
        let myName = (myRecord!["name"] as! String).split(separator: " ").first!
        let friendName = (friendRecord!["name"] as! String).split(separator: " ").first!
        let playlist = PlaylistInput(name: "\(myName) and \(friendName)'s Shuffle")
        
        self.createNewPlaylist(id: id, playlist: playlist) { playlistOutput in
            guard let playlistid = playlistOutput?.id else { return }
            self.addSongs(id: playlistid) {
                print("songs added")
                self.playlistID = playlistid
                self.didPostInSpotify = true
                
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
        
        let joinedTracksURIs = items!.map({$0.uri!}).joined(separator: ",")
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

struct FriendsView: View{
    let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
    
    @ObservedObject var bank: FriendsBank
    
    var body: some View{
        
        VStack{
            
            Text("Shuffle with friends")
                .foregroundColor(Color.black)
                
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .padding()
            
            Text("Press to copy your code:")
                .padding(.leading)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 30, alignment: .leading)
                .foregroundColor(Color.black)
            
            Text(bank.myCode).onLongPressGesture {
                UIPasteboard.general.string = bank.myCode
                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { return }
            }
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color.black)
                .padding([.leading, .trailing])
            
            Text("Write your friend's code:")
                .padding(.leading)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 30, alignment: .leading)
                .foregroundColor(Color.black)
            
            TextField("", text: $bank.friendCode)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .textCase(.uppercase)
                .frame(width: 120, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .multilineTextAlignment(.center)
                .padding()
                
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 4)
                )
                .foregroundColor(Color.black)
            
            Button("Generate"){
                bank.generatePlaylist()
            }
            .padding(.horizontal, 21.0)
            .padding()
                .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(Color(.systemOrange))
            .background(Color(.black))
            .cornerRadius(20)
            .padding()
            
            
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
            
            if bank.hasGenerated{
                Button("Push to Spotify"){
                    bank.pushToSpotify()
                }
                .padding(.horizontal, 10.0)
                .padding(5)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(.systemOrange))
                .background(Color(.black))
                .cornerRadius(20)
                .padding()
            }
            
            
            
            
        }.background(Color.orange)
        .alert(isPresented: $bank.friendDoesNotExist) {
            Alert(title: Text("This code is invalid"), message: Text("Please write another one"), dismissButton: .default(Text("Got it!")))
        }
        .alert(isPresented: $bank.didPostInSpotify){
            Alert(title: Text("Hey, your playlist is in Spotify"), message: Text("Do you want to open it?"), primaryButton: .cancel(), secondaryButton: .default(Text("Let's go!"), action: {
                let url = URL(string: "spotify:playlist:\(bank.playlistID!)")!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
        }
    }
    
    func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
}

struct FriendsViewController_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView(bank: FriendsBank())
    }
}
