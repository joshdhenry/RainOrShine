//
//  WeatherViewTemperatureLabel.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/31/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit

class WeatherViewTemperatureLabel: UILabel {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setLabelStyle()
    }
    
    override func awakeFromNib() {
        setLabelStyle()
    }
    
    func setLabelStyle() {
        self.layer.borderColor = UIColor.green.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        self.layer.zPosition = 999
    }
}
