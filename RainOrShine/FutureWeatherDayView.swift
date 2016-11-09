//
//  FutureWeatherDayView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit

class FutureWeatherDayView: UIVisualEffectView {

    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherConditionView: SKYIconView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "FutureWeatherDayView", bundle: nil).instantiate(withOwner: self, options: nil)
        
        setViewStyle()
        
        addSubview(view)
    }
    
    
    private func setViewStyle() {
        self.setViewEdges()
        
        weatherConditionView.backgroundColor = UIColor.clear
        
        weatherConditionView.setColor = UIColor.white
    }

}
