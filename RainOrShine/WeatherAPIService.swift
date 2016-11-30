//
//  WeatherAPIService.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/29/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import ForecastIO

class WeatherAPIService {
    // MARK: - Properties
    typealias Result = (_ result: Bool) ->()
    
    public var keys: NSDictionary = NSDictionary()
    public var weatherClient: DarkSkyClient?
    
    public var forecastDayDataPointArray: [DataPoint] = [DataPoint]()
    public var currentWeatherForecast: Forecast?
 
 
    // MARK: - Methods
    public func setWeatherClient() {
        weatherClient = DarkSkyClient(apiKey: self.keys["DarkSkyAPIKey"] as! String)
    }
 
 
    public func setCurrentWeatherForecast(latitude: Double, longitude: Double, completion: @escaping Result) {
        //print("In func setCurrentWeatherForecast...")
        
        guard let thisWeatherClient = self.weatherClient else {
            print("Error setting the current weather forecast. Invalid weather client.")
            return
        }
        
        guard (-90...90 ~= latitude && -180...180 ~= longitude) else {
            print("Error - latitude and longitude values used to retrieve weather forecast is out of range.")
            return
        }
        
        let currentSettings = Settings()
        if currentSettings.temperatureUnit == Settings.TemperatureUnitSetting.celcius {
            weatherClient?.units = .si
        }
        else {
            weatherClient?.units = .us
        }
        
        thisWeatherClient.getForecast(latitude: latitude, longitude: longitude) { (result) in
            switch result {
            case .success(let currentForecast, _):
                guard let dailyForecastDataBlock = currentForecast.daily else {
                    completion(true)
                    return
                }
                                
                //Loop through 5 days of data, Skip the first one because that one is today. Append each day's forecast to forecastDayDataPointArray
                for dayForecastIndex in 1..<6 {
                    if (dayForecastIndex < dailyForecastDataBlock.data.count) {
                        let dayForecast = dailyForecastDataBlock.data[dayForecastIndex]
                        self.forecastDayDataPointArray.append(dayForecast)
                        print("TIME OF FUTURE DAY FORECAST - \(dayForecast.time)")
                    }
                }
                
                self.currentWeatherForecast = currentForecast
            case .failure(let error):
                self.currentWeatherForecast = nil
                print("Error retrieving current weather forecast - \(error)")
            }
            completion(true)
        }
    }
    
    
    //Load the Dark Sky API keys from APIKeys.plist
    public func setAPIKeys() {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        self.keys = NSDictionary(contentsOfFile: path)!
    }
}
