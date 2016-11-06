//
//  LocationView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/4/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit

class LocationView: UIVisualEffectView {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    let lightGrayColor = UIColor(netHex: 0xf9f9f9)

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "LocationView", bundle: nil).instantiate(withOwner: self, options: nil)
        
        setViewStyle()
        
        addSubview(view)
    }
    
    
    private func setViewStyle() {
        self.setViewEdges()
        
        self.locationLabel.textColor = lightGrayColor
    }
}
