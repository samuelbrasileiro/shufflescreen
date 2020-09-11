//
//  LoadingOverlay.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 11/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

public class LoadingOverlay{

var overlayView = UIView()
var activityIndicator = UIActivityIndicatorView()
var backgroundView = UIView()
class var shared: LoadingOverlay {
    struct Static {
        static let instance: LoadingOverlay = LoadingOverlay()
    }
    return Static.instance
}

    public func showOverlay(view: UIView) {
        backgroundView.frame = view.bounds
        backgroundView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
        overlayView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        overlayView.center = view.center
        overlayView.backgroundColor = UIColor(red: 0x44/0xff, green: 0x44/0xff, blue: 0x44/0xff, alpha: 0.7)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10

        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .large
        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        
        view.addSubview(backgroundView)
        view.addSubview(overlayView)
        overlayView.addSubview(activityIndicator)

        activityIndicator.startAnimating()
    }

    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        overlayView.removeFromSuperview()
        backgroundView.removeFromSuperview()
    }
}
