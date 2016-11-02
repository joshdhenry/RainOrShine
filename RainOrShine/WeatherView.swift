//
//  WeatherView.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/31/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit

//class WeatherView: UIView {
class WeatherView: UIVisualEffectView {

    //@IBOutlet var view: UIView!
    //@IBOutlet weak var temperatureLabel: WeatherViewTemperatureLabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var temperatureLabel: WeatherViewTemperatureLabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "WeatherView", bundle: nil).instantiate(withOwner: self, options: nil)
        
        /*let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)*/
        //view.backgroundColor = UIColor.clear
        
        addSubview(view)

        //view.frame = self.bounds
        
        /*var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = view.bounds
        visualEffectView.layer.zPosition = 0
        view.addSubview(visualEffectView)*/
        
        
        
    }
    
    /*override init(frame: CGRect) {
        super.init(frame:frame)
    }*/
}
