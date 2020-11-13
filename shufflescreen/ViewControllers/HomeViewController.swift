//
//  MenuViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 08/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit
import CloudKit
import SwiftUI


protocol HomeDelegate{
    func pushVC(identifier: String)
    func getSessionManager() -> SPTSessionManager
}
struct HomeView: View{
    
    @ObservedObject var bank: HomeBank
    
    var body: some View{
        VStack{
            Image("shuffle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 175, minHeight: 0, maxHeight: 175, alignment: .center)
            
            Text("Shuffle")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .padding(.top, -25.0)
            
            
            Text( "\(Locale.current.regionCode == "BR" ? "E aí" : "What's up"), \(bank.user == nil ? "User" : String(bank.user!.displayName!.split(separator: " ")[0]))?")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .frame(alignment: .leading)
            Text(!bank.didAccessTokenLoad ? "Loading Access..." :
                    "You have \(bank.user!.followers!.total!) followers!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .lineLimit(2)
                .frame(alignment: .leading)
            Spacer()
            Button("Discover Tops"){
                if bank.didAccessTokenLoad{
                    bank.delegate?.pushVC(identifier: "UserTopsViewController")
                }
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .frame(width: 200, height: 30, alignment: .center)
            .padding()
            .foregroundColor(Color.orange)
            .background(Color.black)
            .cornerRadius(10)
            
            Button("Shuffle for me"){
                if bank.didAccessTokenLoad{
                    bank.delegate?.pushVC(identifier: "PlaylistViewController")
                }
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .frame(width: 200, height: 30, alignment: .center)
            .padding()
            .foregroundColor(Color.orange)
            .background(Color.black)
            .cornerRadius(10)
            Button("Shuffle with friends"){
                if bank.didAccessTokenLoad{
                    bank.delegate?.pushVC(identifier: "FriendsViewController")
                }
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .frame(width: 200, height: 30, alignment: .center)
            .padding()
            .foregroundColor(Color.orange)
            .background(Color.black)
            .cornerRadius(10)
            Spacer(minLength: 20)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .center)
        .background(Color.orange)
    }
}

class HomeBank: ObservableObject{
    
    @Published var user: User?
    
    @Published var didAccessTokenLoad: Bool = false
    
    var delegate: HomeDelegate?
    
    init(){
        if let user = User.restore(){
            self.user = user
        }
        else{
            User.fetch{ result in
                if case .success(let user) = result {
                    print("adobabedobedo")
                    self.user = user
                    User.archive(user: user)
                    
                    self.archiveCloudKit(user: user)
                    
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            if !(self.delegate?.getSessionManager().session!.isExpired)!{
                self.didAccessTokenLoad = true
                timer.invalidate()
            }
        }
        
    }
    
    func archiveCloudKit(user: User){
        let publicDatabase = CKContainer(identifier: "iCloud.samuel.shufflescreen").publicCloudDatabase
        let defaults = UserDefaults(suiteName: "group.samuel.shufflescreen.app")!
        
        let record = CKRecord(recordType: "SPTUser")
        
        record.setValue(user.displayName, forKey: "name")
        record.setValue(user.id, forKey: "id")
        
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let code = String((0...4).map{ _ in letters.randomElement()! })
        record.setValue(code, forKey: "code")
        
        defaults.setValue(code, forKey: Keys.kICloudCode)
        defaults.setValue(Date(), forKey: Keys.kICloudModificationDate)
        defaults.setValue(record.recordID.recordName, forKey: Keys.kICloudRecordName)
        
        publicDatabase.save(record) { (savedRecord, error) in
            
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

class HomeViewController: BaseViewController, HomeDelegate {
    func getSessionManager() -> SPTSessionManager {
        return sessionManager
    }
    
    func pushVC(identifier: String) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: identifier)
        self.navigationController!.pushViewController(vc, animated: true)
        
    }
    
    
    var child: UIHostingController<HomeView>?
    var bank: HomeBank = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bank.delegate = self
        let homeView = HomeView(bank: bank)
        
        child = UIHostingController(rootView: homeView)
        
        child?.view.backgroundColor = .clear
        child?.view.translatesAutoresizingMaskIntoConstraints = false
        child?.overrideUserInterfaceStyle = .light
        
        self.view.addSubview(child!.view)
        
        let constraints = [
            child!.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            child!.view.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
            child!.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            child!.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            child!.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
    
}
