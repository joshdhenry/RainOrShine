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
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "LocationView", bundle: nil).instantiate(withOwner: self, options: nil)
        roundViewEdges()
        addSubview(view)
    }
    
    
    private func roundViewEdges() {
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
}
