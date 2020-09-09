//
//  UIViewController+resetWindow.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

// extension for resetting the window on a UIKit application
extension UIViewController {
    var appRemoteSD: SPTAppRemote {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            fatalError("could not get scene delegate ")
        }
        return sceneDelegate.appRemote
    }
}
