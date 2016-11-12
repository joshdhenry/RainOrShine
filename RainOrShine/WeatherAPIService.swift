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
    static private var keys: NSDictionary = NSDictionary()
    static private var weatherClient: DarkSkyClient?
    
    static var currentWeatherForecast: Forecast?
    
    static var forecastDayDataPointArray: [DataPoint] = [DataPoint]()
        
    
    //Private initializer prevents any outside code from using the default '()' initializer for this class, which could create duplicates of LocationAPIService
    private init() {}
    
    
    class public func setWeatherClient() {
        WeatherAPIService.weatherClient = DarkSkyClient(apiKey: WeatherAPIService.keys["DarkSkyAPIKey"] as! String)
    }
    
    
    class public func setCurrentWeatherForecast(latitude: Double, longitude: Double, completion: @escaping (_ result: Bool) ->()) {
        //print("In func setCurrentWeatherForecast...")
        WeatherAPIService.weatherClient?.getForecast(latitude: latitude, longitude: longitude) { (result) in
            //print("Retrieved forecast from server...")
            switch result {
            case .success(let currentForecast, let requestMetadata):
                
                //THIS IS JUST A TEMPORARY ELSE.  NOT SURE IF I SHOULD RETURN SO DEFINITELY CHECK BEFORE YOU LEAVE IT
                guard let dailyForecastDataBlock = currentForecast.daily else {return}
                                
                //Loop through 5 days of data, Skip the first one because that one is today
                for dayForecastIndex in 1..<6 {
                    if (dayForecastIndex < dailyForecastDataBlock.data.count) {
                        //DOUBLE CHECK IF I CAN AND SHOULD RETURN IN THIS ELSE STATEMENT.  SO SLEEPY RIGHT NOW.
                        let dayForecast = dailyForecastDataBlock.data[dayForecastIndex]
                        print(dayForecast.time)
                        
                        forecastDayDataPointArray.append(dayForecast)
                    }
                }
                
                WeatherAPIService.currentWeatherForecast = currentForecast
            case .failure(let error):
                WeatherAPIService.currentWeatherForecast = nil
                print("Error retrieving current weather forecast - \(error)")
            }
            completion(true)
        }
    }
    
    
    //Load the Dark Sky API keys from APIKeys.plist
    class public func setAPIKeys() {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        WeatherAPIService.keys = NSDictionary(contentsOfFile: path)!
    }
}
