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
    @IBOutlet weak var temperatureLabel: WeatherViewTemperatureLabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "WeatherView", bundle: nil).instantiate(withOwner: self, options: nil)
        roundViewEdges()
        addSubview(view)
    }
    
    
    private func roundViewEdges() {
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
}
