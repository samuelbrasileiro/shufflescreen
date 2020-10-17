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
    
}
struct HomeView: View{
    
    @ObservedObject var bank: HomeBank
    var delegate: HomeDelegate?
    
    var body: some View{
        VStack{
            Spacer(minLength: 40)
            Text("Shuffle")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .padding()
            
            Text("E aí, \(bank.user == nil ? "beleza" : String(bank.user!.displayName!.split(separator: " ")[0]))?")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .frame(alignment: .leading)
            Text(bank.user == nil ? "Carregando conta..." : "Você está com \(bank.user!.followers!.total!) seguidores!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .lineLimit(2)
                .frame(alignment: .leading)
            Spacer()
            Button("Discover Tops"){
                delegate?.pushVC(identifier: "UserTopsViewController")
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .frame(width: 200, height: 30, alignment: .center)
            .padding()
            .foregroundColor(Color.orange)
            .background(Color.black)
            .cornerRadius(10)
            
            Button("Shuffle for me"){
                delegate?.pushVC(identifier: "PlaylistViewController")
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .frame(width: 200, height: 30, alignment: .center)
            .padding()
            .foregroundColor(Color.orange)
            .background(Color.black)
            .cornerRadius(10)
            Button("Shuffle with friends"){
                delegate?.pushVC(identifier: "FriendsViewController")
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .frame(width: 200, height: 30, alignment: .center)
            .padding()
            .foregroundColor(Color.orange)
            .background(Color.black)
            .cornerRadius(10)
            Spacer(minLength: 20)
        }
        .frame(minWidth: 0, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(Color.orange)
    }
}

class HomeBank: ObservableObject{
    @Published var user: User?
    
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
    func pushVC(identifier: String) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: identifier)
        self.navigationController!.pushViewController(vc, animated: true)
        
    }
    
    
    var child: UIHostingController<HomeView>?
    var bank: HomeBank = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var homeView = HomeView(bank: bank)
        homeView.delegate = self
        child = UIHostingController(rootView: homeView)
        
        child?.view.backgroundColor = .clear
        child?.view.translatesAutoresizingMaskIntoConstraints = true
        child?.overrideUserInterfaceStyle = .light
        child?.view.frame = self.view.safeAreaLayoutGuide.layoutFrame
        self.view.addSubview(child!.view)
    }
    
}

