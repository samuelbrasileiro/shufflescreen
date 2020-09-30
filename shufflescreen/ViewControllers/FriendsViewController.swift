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
        child?.view.frame = CGRect(x: self.view.bounds.midX - 200, y: 90, width: 400, height: self.view.bounds.height - 50 - 30)
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
    
    var myCode: String
    
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
        let myArtistsIDs = self.myRecord!["artistsIDs"] as! [String]
        let myTracksIDs = self.myRecord!["trackIDs"] as! [String]
        
        let friendArtistsIDs = self.friendRecord!["artistsIDs"] as! [String]
        let friendTracksIDs = self.friendRecord!["trackIDs"] as! [String]
        
        let interleavedArtists = zip(myArtistsIDs, friendArtistsIDs).flatMap { [$0, $1] }
        let interleavedArtistsWithPriority = (0 ..< interleavedArtists.count).map{(interleavedArtists[$0], $0, 1)}
        
        let normalizedArtists = interleavedArtistsWithPriority.reduce([String:(Int,Int)]()) {
            var dict = $0
            dict[$1.0] = (dict[$1.0] ?? (0,0))
            dict[$1.0]!.0 += $1.1/2
            print($1.1)
            dict[$1.0]!.1 += $1.2
            return dict
            }.map{$0}

        let orderedArtists = normalizedArtists.sorted{
            if $0.value.1 == $1.value.1{
                return $0.value.0 < $1.value.0
            }
            else{
                return $0.value.1 > $1.value.1
            }
        }
        print(orderedArtists)
        
        let myTracks = [Track]()
        let friendTracks = [Track]()
        
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
                        print(results!.count)
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
            
            
            ScrollView{
                
            }.background(Color(.red))
            if bank.hasGenerated{
                Button("Push to Spotify"){
                    
                }
                .padding(.horizontal, 10.0)
                .padding()
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
