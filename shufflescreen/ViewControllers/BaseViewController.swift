//
//  UIViewController+resetWindow.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

// extension for resetting the window on a UIKit application
class BaseViewController: UIViewController {
    
    
    var sceneDelegate: SceneDelegate{
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            fatalError("could not get scene delegate ")
        }
        return sceneDelegate
    }
    var appRemote: SPTAppRemote {
        return sceneDelegate.appRemote
    }
    var sessionManager: SPTSessionManager{
        return sceneDelegate.sessionManager
    }
    
    var disconnectedView = DisconnectedView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disconnectedView.alpha = 0.8
        disconnectedView.frame = CGRect(x: self.view.bounds.midX - 170, y: 80, width: 340, height: 100)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showDisconnectedView), name: NSNotification.Name(rawValue: "deviceIsDisconnected"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideDisconnectedView), name: NSNotification.Name(rawValue: "deviceIsConnected"), object: nil)
    }
    
    @objc func showDisconnectedView(){
        self.view.addSubview(disconnectedView)
    }
    
    @objc func hideDisconnectedView(){
        //disconnectedView.isHidden = true
        disconnectedView.removeFromSuperview()
    }
}
