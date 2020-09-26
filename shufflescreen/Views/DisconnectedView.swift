//
//  DisconnectView.swift
//  shufflescreen
//
//  Created by Samuel Brasileiro on 09/09/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

class DisconnectedView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    func commonInit(){
        
        Bundle.main.loadNibNamed("DisconnectedView", owner: self, options: nil)
        self.addSubview(contentView)
        self.setCornerRadius(10)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
}
