//
//  BaseNavigationController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 10/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    var sceneDelegate: SceneDelegate{
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            fatalError("could not get scene delegate ")
        }
        return sceneDelegate
    }
    var appRemote: SPTAppRemote {
        return sceneDelegate.appRemote
    }
    
    let appRemoteButton = LatealButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        appRemoteButton.frame = CGRect(origin: CGPoint(x: self.view.bounds.width-74, y: self.view.bounds.height - 200), size: CGSize(width: 64, height: 64))
        appRemoteButton.backgroundColor = .black
        
        let image = UIImage(named: "spotify")
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        appRemoteButton.setImage(tintedImage, for: .normal)
        
        appRemoteButton.setCornerRadius(appRemoteButton.bounds.midX)
        
        appRemoteButton.addTarget(self, action: #selector(goToAppRemoteView), for: .touchUpInside)
        
        self.view.addSubview(appRemoteButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectedToAppRemote), name: NSNotification.Name(rawValue: "connectedToAppRemote"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectedFromAppRemote), name: NSNotification.Name(rawValue: "disconnectedFromAppRemote"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(couldNotConnectToAppRemote), name: NSNotification.Name(rawValue: "couldNotConnectToAppRemote"), object: nil)
        
        if appRemote.isConnected{
            appRemoteButton.tintColor = .systemGreen
        }
        else{
            appRemoteButton.tintColor = .systemGray3
            appRemote.connect()
        }
    }
    
    @objc func goToAppRemoteView(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AppRemoteViewController")
                
        self.pushViewController(vc, animated: true)
    }
    
    @objc func connectedToAppRemote(){
        appRemoteButton.tintColor = .systemGreen
    }
    
    @objc func disconnectedFromAppRemote(){
        appRemoteButton.tintColor = .systemGray3
    }
    
    @objc func couldNotConnectToAppRemote(){
        appRemoteButton.tintColor = .systemGray3
    }
}
