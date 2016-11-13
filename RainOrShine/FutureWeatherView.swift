//
//  FutureWeatherView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit
import ForecastIO

class FutureWeatherView: UIView {

    @IBOutlet var view: UIView!
    
    @IBOutlet weak var day1View: FutureWeatherDayView!
    
    
    var viewModel: FutureWeatherViewModel? {
        didSet {
            viewModel?.currentForecast.observe { [unowned self] in
                //I SHOULD BE ABLE TO ERASE THIS WITHOUT CONSEQUENCE, BUT IT WONT LET ME
                guard let forecast: Forecast = $0 else {return}
                
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
                            
                            var temperatureLabelText: String = String()
                            
                            //MAKE A DICTIONARY WITH THE MIN AND MAX.  CREATE AN EXTENSION OF A DICTIONARY THAT WILL BE CALLED getFormattedTemperatureRANGEString and implement it here
                            let minTemperatureText = WeatherAPIService.forecastDayDataPointArray[futureDaySubViewIndex].temperatureMin?.getFormattedTemperatureString() ?? ""
                            let maxTemperatureText = WeatherAPIService.forecastDayDataPointArray[futureDaySubViewIndex].temperatureMax?.getFormattedTemperatureString() ?? ""
                            
                            temperatureLabelText = minTemperatureText + "/" + maxTemperatureText
                            
                            futureDayView.temperatureLabel.text = temperatureLabelText
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
    
    
    func initializeViewModel() {
        print("Initializing photo detail view model...")
        self.viewModel = FutureWeatherViewModel()
    }
}
