//
//  FutureWeatherView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit
import ForecastIO

class FutureWeatherView: UIView, WeatherViewControllerSubView {

    @IBOutlet var view: UIView!
    
    
    var viewModel: FutureWeatherViewModel? {
        didSet {
            viewModel?.currentForecast.observe { [unowned self] in
                guard let _: Forecast = $0 else {return}
                
                //Get the 5 day forecast
                var futureDaySubViewsArray: [UIView] = [UIView]()
                
                if (!WeatherAPIService.forecastDayDataPointArray.isEmpty) {
                    for thisView in self.allSubViews {
                        if let futureDayView = thisView as? FutureWeatherDayView {
                            futureDaySubViewsArray.append(futureDayView)
                        }
                    }
                    futureDaySubViewsArray.sort(by: { $0.center.x < $1.center.x })
                }
                
                //Update the UI on the main thread
                DispatchQueue.main.async {
                    //Populate five day forecast from the sorted array
                    for futureDaySubViewIndex in 0..<futureDaySubViewsArray.count {
                        if let futureDayView = futureDaySubViewsArray[futureDaySubViewIndex] as? FutureWeatherDayView {
                            futureDayView.summaryLabel.text = WeatherAPIService.forecastDayDataPointArray[futureDaySubViewIndex].summary
                            futureDayView.weatherConditionView.setType = WeatherAPIService.forecastDayDataPointArray[futureDaySubViewIndex].icon?.getSkycon() ?? Skycons.partlyCloudyDay
                            futureDayView.weatherConditionView.play()
                            
                            futureDayView.dayLabel.text = WeatherAPIService.forecastDayDataPointArray[futureDaySubViewIndex].time.toAbbreviatedDayString()
                            
                            let minMaxTemperatureDictionary = (min: WeatherAPIService.forecastDayDataPointArray[futureDaySubViewIndex].temperatureMin?.formattedTemperatureString ?? "", max: WeatherAPIService.forecastDayDataPointArray[futureDaySubViewIndex].temperatureMax?.formattedTemperatureString ?? "")

                            futureDayView.temperatureLabel.text = minMaxTemperatureDictionary.min + "/" + minMaxTemperatureDictionary.max
                        }
                    }
                }
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "FutureWeatherView", bundle: nil).instantiate(withOwner: self, options: nil)
                
        addSubview(view)
        
        initializeViewModel()
    }
    
    
    internal func initializeViewModel() {
        print("Initializing photo detail view model...")
        self.viewModel = FutureWeatherViewModel()
    }
    
    
    internal func setViewStyle() {}
}
