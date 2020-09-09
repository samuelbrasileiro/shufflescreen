//
//  ViewController.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 06/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit


class LoginViewController: BaseViewController {
        
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadingActivityIndicator.stopAnimating()
        NotificationCenter.default.addObserver(self, selector: #selector(segueFromLogin), name: NSNotification.Name(rawValue: "sessionConnected"), object: nil)
        
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        loadingActivityIndicator.startAnimating()
        NotificationCenter.default.post(name: Notification.Name("loginButtonPressed"), object: nil)
        
    }
    @objc func segueFromLogin(){
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "loginToHome", sender: self)
        }
        
    }
}

extension LoginViewController{
    
    // MARK: - SPTSessionManagerDelegate
    
    
    private func presentAlertController(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
    }
}
