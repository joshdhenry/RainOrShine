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
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "WeatherView", bundle: nil).instantiate(withOwner: self, options: nil)
        setTemperatureLabelStyle()
        roundViewEdges()
        addSubview(view)
    }
    
    
    private func roundViewEdges() {
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
    
    func setTemperatureLabelStyle() {
        self.layer.borderColor = UIColor.green.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
    }
}
