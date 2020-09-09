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
}
