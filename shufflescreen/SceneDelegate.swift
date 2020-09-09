//
//  SceneDelegate.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 06/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate, SPTSessionManagerDelegate {
    
    var window: UIWindow?
    var reachability: Reachability!
    
    static private let kAccessTokenKey = "access-token-key"
    static private let kRefreshTokenKey = "refresh-token-key"
    let SpotifyClientID = "c7e5c5b3c1164878aaf84f3c14187411"
    let SpotifyRedirectURL = URL(string: "shufflescreen://spotify-login-callback")!
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL)
        
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        if let tokenSwapURL = URL(string: "https://shufflescreen.herokuapp.com/api/token"),
            let tokenRefreshURL = URL(string: "https://shufflescreen.herokuapp.com/api/refresh_token") {
            self.configuration.tokenSwapURL = tokenSwapURL
            self.configuration.tokenRefreshURL = tokenRefreshURL
            self.configuration.playURI = ""
        }
        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
        
        return manager
    }()
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .info)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: SceneDelegate.kAccessTokenKey)
        }
    }
    var refreshToken = UserDefaults.standard.string(forKey: kRefreshTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(refreshToken, forKey: SceneDelegate.kRefreshTokenKey)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let url = URLContexts.first?.url else {
            return
        }
        
        sessionManager.application(UIApplication.shared, open: url, options: [:])
        
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("bummer")
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("sweet")
    }
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
        
        self.accessToken = session.accessToken
        self.refreshToken = session.refreshToken
        appRemote.connectionParameters.accessToken = session.accessToken
        
        //NotificationCenter.default.post(name: Notification.Name("sessionConnected"), object: nil)
    }
    
    @objc func createSession(){
        if reachability.connection != .unavailable {
            
            let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate, .playlistReadCollaborative, .userLibraryRead, .playlistModifyPublic, .userFollowRead, .userTopRead]
            //sessionManager.alwaysShowAuthorizationDialog = false
            if #available(iOS 11, *) {
                // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
                
                sessionManager.initiateSession(with: scope, options: .clientOnly)
            } else {
                // Use this on iOS versions < 11 to use SFSafariViewController
                sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: viewController.self)
            }
            
            if reachability.connection == .wifi {
                print("Conectado via WiFi")
            } else {
                print("Conectado via Celular")
            }
        } else {
            print("Desconectado da internet")
        }
        
        
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        // Connection was successful, you can begin issuing commands
        print("connected")
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            
        })
        
        NotificationCenter.default.post(name: Notification.Name("sessionConnected"), object: nil)
    }
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
    }
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed")
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
        if self.appRemote.isConnected{
            return
        }
        if let _ = self.appRemote.connectionParameters.accessToken {
            print("push it")
            print(self.appRemote.connectionParameters.accessToken)
            self.appRemote.connect()
            
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        if self.appRemote.isConnected {
            print("pull it")
            //self.appRemote.disconnect()
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //scene did begin
        
        do {
            try reachability = Reachability()
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: reachability)
            try reachability.startNotifier()
        } catch {
            print("This is not working.")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(createSession), name: NSNotification.Name(rawValue: "loginButtonPressed"), object: nil)
    }
    
    @objc func reachabilityChanged(_ note: NSNotification) {
        let reachability = note.object as! Reachability
        if reachability.connection != .unavailable {
            
            NotificationCenter.default.post(name: Notification.Name("deviceIsConnected"), object: nil)
            if reachability.connection == .wifi {
                print("Conectado via WiFi")
            } else {
                print("Conectado via Celular")
            }
            
        } else {
            print("Desconectado da internet")
            NotificationCenter.default.post(name: Notification.Name("deviceIsDisconnected"), object: nil)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
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
    
    var viewController: UIViewController {
        get {
            print("hehe")
            if let navController = self.window?.rootViewController as? UINavigationController{
                return navController.topViewController!
            }
            else{
                return (self.window?.rootViewController)!
            }
        }
    }
}

extension SceneDelegate: SPTAppRemotePlayerStateDelegate{
    
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("Track name: ", playerState.track.name)
        NotificationCenter.default.post(name: Notification.Name("updatePlayerState"), object: nil)
    }
}
