//
//  WeatherView.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/31/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit

class WeatherView: UIVisualEffectView {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!

    
    let lightGrayColor = UIColor(netHex: 0xf9f9f9)
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "WeatherView", bundle: nil).instantiate(withOwner: self, options: nil)
        setViewStyle()
        addSubview(view)
    }
    

    private func setViewStyle() {
        self.setViewEdges()
        
        self.temperatureLabel.textColor = UIColor(netHex: ColorScheme.lightGray)
        self.summaryLabel.textColor = UIColor(netHex: ColorScheme.lightGray)
    }
}
