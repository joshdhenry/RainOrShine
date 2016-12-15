//
//  FutureWeatherView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit
import ForecastIO

//FutureWeatherView is the view that holds 5 FutureWeatherDayViews for the 5 day forecast
class FutureWeatherView: UIView, WeatherViewControllerSubView {
    
    // MARK: - Properties
    @IBOutlet var view: UIView!
    
    // MARK: View Model
    var viewModel: FutureWeatherViewModel? {
        didSet {
            viewModel?.currentForecastDayDataPointArray.observe { [unowned self] in
                guard let fiveDayForecastArray: [DataPoint] = $0 else {return}
                
                guard (!fiveDayForecastArray.isEmpty) else {
                    self.isHidden = true
                    return
                }
                
                //Get the 5 day forecast.
                var futureDaySubViewsArray: [UIView] = [UIView]()
                
                //Collect all futureDayView's in futureDaySubViewsArray, then sort them based on X-position.
                for thisView in self.allSubViews {
                    if let futureDayView = thisView as? FutureWeatherDayView {
                        futureDaySubViewsArray.append(futureDayView)
                    }
                }
                futureDaySubViewsArray.sort(by: { $0.center.x < $1.center.x })
                
                //Update the UI on the main thread
                DispatchQueue.main.async {
                    //Populate five day forecast from the sorted array
                    for futureDaySubViewIndex in 0..<futureDaySubViewsArray.count {
                        if let futureDayView = futureDaySubViewsArray[futureDaySubViewIndex] as? FutureWeatherDayView {
                            futureDayView.summaryLabel.text = fiveDayForecastArray[futureDaySubViewIndex].summary
                            futureDayView.weatherConditionView.setType = fiveDayForecastArray[futureDaySubViewIndex].icon?.getSkycon() ?? Skycons.partlyCloudyDay
                            futureDayView.weatherConditionView.play()
                            
                            //NSLog("---")
                            //NSLog("Forecast Time -\(fiveDayForecastArray[futureDaySubViewIndex].time)")
                            //NSLog("Abbrev. day string - \(fiveDayForecastArray[futureDaySubViewIndex].time.getAbbreviatedDayString(timeZoneIdentifier: (self.viewModel?.currentTimeZoneIdentifier.value)!))")
                            
                            futureDayView.dayLabel.text = fiveDayForecastArray[futureDaySubViewIndex].time.getAbbreviatedDayString(timeZoneIdentifier: (self.viewModel?.currentTimeZoneIdentifier.value)!)
                            
                            let minMaxTemperatureDictionary = (min: fiveDayForecastArray[futureDaySubViewIndex].temperatureMin?.formattedTemperatureString ?? "", max: fiveDayForecastArray[futureDaySubViewIndex].temperatureMax?.formattedTemperatureString ?? "")

                            futureDayView.temperatureLabel.text = minMaxTemperatureDictionary.min + "/" + minMaxTemperatureDictionary.max
                        }
                    }
                }
                self.isHidden = false
            }
        }
    }
    
    
    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "FutureWeatherView", bundle: nil).instantiate(withOwner: self, options: nil)
                
        addSubview(view)
    }
    
    
    internal func setViewStyle() {}
}
