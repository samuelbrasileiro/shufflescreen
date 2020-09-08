//
//  ViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 06/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {
    
    //var auth = SPTAuth.defaultInstance()!
    var loginURL: URL?
    //var session: SPTSession!
    let clientID = "c7e5c5b3c1164878aaf84f3c14187411"
    let redirectURL = URL(string: "shufflescreen://spotify-login-callback")!
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: clientID, redirectURL: redirectURL)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = ""

        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        //configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        //configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        //appRemote.delegate = self
        return appRemote
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //UserDefaults.standard.removeObject(forKey: "SpotifySession")
        //if let session = SPTConfiguration.session{
            //self.session = session
            
//            print("Login efetuado")
//            Timer.scheduledTimer(withTimeInterval: 2, repeats: false){_ in
//                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlaylistsViewController")
//                self.present(vc,animated: true)
//            }
//        }
//        else {
//            print("Redirecionando ao spotify")
//        }
    }
    
    func configureRequest(){
//        auth.redirectURL = SPTConfiguration.redirectURL
//        auth.clientID = SPTConfiguration.clientID
//
//        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistReadCollaborativeScope, SPTAuthUserReadTopScope, SPTAuthUserLibraryReadScope, SPTAuthUserFollowReadScope]
//
//        loginURL = auth.spotifyAppAuthenticationURL()
    }
    
    @objc func updateAfterFirstLogin (){
//        let userDefaults = UserDefaults.standard
//
//        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
//            do{
//                let sessionData = sessionObj as! Data
//                let sessionDecoded = try NSKeyedUnarchiver.unarchivedObject(ofClass: SPTSession.self, from: sessionData)
//                self.session = sessionDecoded
//                performSegue(withIdentifier: "LoginToPlaylists", sender: nil)
//            }
//            catch{
//                print(error)
//            }
//        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        configureRequest()
        print(loginURL)
        
        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate, .playlistReadCollaborative,.userLibraryRead,.playlistModifyPublic,.userFollowRead,.userTopRead]

        if #available(iOS 11, *) {
            // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
            sessionManager.initiateSession(with: scope, options: .clientOnly)
        } else {
            // Use this on iOS versions < 11 to use SFSafariViewController
            sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
        }
        
        
//        UIApplication.shared.open(loginURL! as URL, options: [ : ]) { (success) in
//            if success{
//                //     if UIApplication.shared.openURL(loginURL!) {
//                if self.auth.canHandle(self.auth.redirectURL) {
//                    print("dois")
//
//                    NotificationCenter.default.addObserver(self, selector: #selector(self.updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
//
//                }
//            }
//        }
        
    }
    
    
}

extension LoginViewController: SPTSessionManagerDelegate{
    
    // MARK: - SPTSessionManagerDelegate

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
        
    }
    
    
    private func presentAlertController(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
    }
}
