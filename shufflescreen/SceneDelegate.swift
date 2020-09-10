//
//  SceneDelegate.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 06/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit
class Keys{
    static let kAccessTokenKey = "access-token-key"
    static let kRefreshTokenKey = "refresh-token-key"
    static let kSessionKey = "session-key"
}
class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate, SPTSessionManagerDelegate {
    
    var window: UIWindow?
    var reachability: Reachability!
    
    let SpotifyClientID = "c7e5c5b3c1164878aaf84f3c14187411"
    let SpotifyRedirectURL = URL(string: "shufflescreen://spotify-login-callback")!
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL)
        configuration.playURI = ""
        if let tokenSwapURL = URL(string: "https://shufflescreen.herokuapp.com/api/token"),
            let tokenRefreshURL = URL(string: "https://shufflescreen.herokuapp.com/api/refresh_token") {
            configuration.tokenSwapURL = tokenSwapURL
            configuration.tokenRefreshURL = tokenRefreshURL
            
        }
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
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .error)
        
        appRemote.connectionParameters.accessToken = UserDefaults.standard.string(forKey: Keys.kAccessTokenKey)
        appRemote.delegate = self
        return appRemote
    }()
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let url = URLContexts.first?.url else {
            return
        }
        
        sessionManager.application(UIApplication.shared, open: url, options: [:])
        
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        DispatchQueue.main.async {
            print("Não foi possível estabelecer uma sessão.", error)
        }
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        DispatchQueue.main.async {
            //self.appRemote.authorizeAndPlayURI(self.configuration.playURI!)
            
            self.appRemote.connectionParameters.accessToken = session.accessToken
            self.appRemote.connect()
            
            print("renewed", session)
            
            self.archiveSession(session)
            
            NotificationCenter.default.post(name: Notification.Name("sessionConnected"), object: nil)
        }
    }
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
        
        print("Access token: \(session.accessToken), expires at \(session.expirationDate)")
        
        archiveSession(session)
        
        NotificationCenter.default.post(name: Notification.Name("sessionConnected"), object: nil)
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
            
        }
        
        
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        // Connection was successful, you can begin issuing commands
        print("Connected App Remote")
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            //            if let error = error {
            //                debugPrint(error.localizedDescription)
            //            }
            
        })
        
        
    }
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Disconnected App Remote")
    }
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Failed Connection to App Remote")
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
        if self.appRemote.isConnected{
            return
        }
        
        if let _ = self.appRemote.connectionParameters.accessToken {
            print("Connecting to App Remote")
            self.appRemote.connect()
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        if self.appRemote.isConnected {
            print("Disconnecting from App Remote")
            self.appRemote.disconnect()
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //scene did begin
        restoreSession()
        sessionManager.renewSession()
        
        do {
            try reachability = Reachability()
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: reachability)
            try reachability.startNotifier()
        } catch {
            print("It's not possible to access reachability.")
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
    
    func archiveSession(_ session: SPTSession) {
        do {
            
            UserDefaults.standard.set(session.accessToken, forKey: Keys.kAccessTokenKey)
            UserDefaults.standard.set(session.refreshToken, forKey: Keys.kRefreshTokenKey)
            
            let sessionData = try NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: true)
            UserDefaults.standard.set(sessionData, forKey: Keys.kSessionKey)
            
            
        } catch {
            print("Failed to archive session: \(error)")
        }
    }
    
    private func restoreSession() {
        guard let sessionData = UserDefaults.standard.data(forKey: Keys.kSessionKey) else { return }
        do {
            let session = try NSKeyedUnarchiver.unarchivedObject(ofClass: SPTSession.self, from: sessionData)
            print("saved")
            sessionManager.session = session
        } catch {
            print("error unarchiving session: \(error)")
        }
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(name: Notification.Name.reachabilityChanged, object: reachability)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
    
    var viewController: UIViewController {
        get {
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
