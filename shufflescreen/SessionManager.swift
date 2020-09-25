//
//  SessionManager.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 25/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import Foundation

class WidgetSessionManager: NSObject, SPTSessionManagerDelegate{
    
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
        
        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
        
        return manager
    }()
    
    override init() {
        super.init()
        
        restoreSession()
        if let session = sessionManager.session{
            if session.isExpired{
                sessionManager.renewSession()
            }
        }
        else{
            let scope: SPTScope = [.userReadPlaybackState, .userReadCurrentlyPlaying, .appRemoteControl, .playlistReadPrivate, .playlistReadCollaborative, .userLibraryRead, .playlistModifyPublic, .userFollowRead, .userTopRead]

            sessionManager.initiateSession(with: scope, options: .clientOnly)
            
            
        }
        
    }
    
    private func restoreSession() {
        guard let sessionData = defaults.data(forKey: Keys.kSessionKey) else { return }
        do {
            let session = try NSKeyedUnarchiver.unarchivedObject(ofClass: SPTSession.self, from: sessionData)
            sessionManager.session = session
        } catch {
            print("error unarchiving session: \(error)")
        }
    }
    
    func archiveSession(_ session: SPTSession) {
        do {
            
            defaults.set(session.accessToken, forKey: Keys.kAccessTokenKey)
            defaults.set(session.refreshToken, forKey: Keys.kRefreshTokenKey)
            
            let sessionData = try NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: true)
            defaults.set(sessionData, forKey: Keys.kSessionKey)
            
            
        } catch {
            print("Failed to archive session: \(error)")
        }
    }
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        self.archiveSession(session)
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        self.archiveSession(session)
    }
}
