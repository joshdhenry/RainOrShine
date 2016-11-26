//
//  CurrentWeatherView.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/31/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit
import ForecastIO

class CurrentWeatherView: UIVisualEffectView, WeatherViewControllerSubView {
    // MARK: - Properties
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var weatherConditionView: SKYIconView!

    // MARK: View Model
    var viewModel: CurrentWeatherViewModel? {
        didSet {
            viewModel?.currentForecast.observe { [unowned self] in
                guard let forecast: Forecast = $0 else {
                    self.isHidden = true
                    return
                }
                guard let currently = forecast.currently else {return}
                
                //Update the UI on the main thread
                DispatchQueue.main.async {
                    self.temperatureLabel.text = currently.temperature?.formattedTemperatureString ?? ""
                    self.summaryLabel.text = currently.summary
                    self.weatherConditionView.setType =  currently.icon?.getSkycon() ?? Skycons.partlyCloudyDay
                    self.weatherConditionView.play()
                    self.isHidden = false
                    self.fadeIn()
                }
            }
            /*viewModel?.currentTemperatureUnit.observe { [unowned self] in
                
                
                print("TEMPERATURE UNIT CHANGED.  REFLECTING CHANGES IN VIEW MODEL... - \($0)")
                
                guard let currentTemperatureUnit: Settings.TemperatureUnitSetting = $0 else {
                    return
                }
                guard let currently = self.viewModel?.currentForecast.value?.currently else {return}
                
                //Update the UI on the main thread
                DispatchQueue.main.async {
                    self.temperatureLabel.text = currently.temperature?.formattedTemperatureString ?? ""
                }
            }*/
        }
    }
    
    
    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "CurrentWeatherView", bundle: nil).instantiate(withOwner: self, options: nil)
        setViewStyle()
        addSubview(view)
    }
    

    internal func setViewStyle() {
        self.setViewEdges()
        
        self.temperatureLabel.textColor = UIColor.white
        self.summaryLabel.textColor = UIColor.white
        
        weatherConditionView.backgroundColor = UIColor.clear
        weatherConditionView.setColor = UIColor.white
    }
}
