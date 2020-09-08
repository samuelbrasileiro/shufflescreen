//
//  SceneDelegate.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 06/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    //var auth = SPTAuth()
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        if let url = URLContexts.first?.url {
//            if auth.canHandle(auth.redirectURL) {
//                // 3 - handle callback in closure
//                auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
//                    // 4- handle error
//                    if let error = error {
//                        print(error)
//                        return
//                    }
//                    // 5- Add session to User Defaults
//                    let array = url.absoluteString.components(separatedBy: "=")
//                    let spotifycode = array[1]
//                    print(spotifycode)
//                    let userDefaults = UserDefaults.standard
//                    userDefaults.set(spotifycode, forKey: "SpotifyCode")
//
//                    do{
//                        let sessionData = try NSKeyedArchiver.archivedData(withRootObject: session!, requiringSecureCoding: false)
//
//                        userDefaults.set(sessionData, forKey: "SpotifySession")
//                        userDefaults.synchronize()
//
//                        NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
//                        print("Sucessfully connected to Spotify application.")
//                    }
//                    catch{
//                        print(error)
//                    }
//                })
//            }
//        }
    }
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
//        auth.redirectURL = URL(string: "MusiCorreria://returnAfterLogin")
//        auth.sessionUserDefaultsKey = "current session"
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

