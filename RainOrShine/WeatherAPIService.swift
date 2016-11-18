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
        //print("In func setWeatherClient...")
        weatherClient = DarkSkyClient(apiKey: self.keys["DarkSkyAPIKey"] as! String)
    }
 
 
    public func setCurrentWeatherForecast(latitude: Double, longitude: Double, completion: @escaping Result) {
        //print("In func setCurrentWeatherForecast...")
        
        guard let thisWeatherClient = self.weatherClient else {
            print("Error setting the current weather forecast. Invalid weather client.")
            return
        }
        
        thisWeatherClient.getForecast(latitude: latitude, longitude: longitude) { (result) in
            //print("Retrieved forecast from server...")
            switch result {
            case .success(let currentForecast, _):
                //THIS IS JUST A TEMPORARY ELSE.  NOT SURE IF I SHOULD RETURN SO DEFINITELY CHECK BEFORE YOU LEAVE IT
                guard let dailyForecastDataBlock = currentForecast.daily else {return}
                                
                //Loop through 5 days of data, Skip the first one because that one is today
                for dayForecastIndex in 1..<6 {
                    if (dayForecastIndex < dailyForecastDataBlock.data.count) {
                        //DOUBLE CHECK IF I CAN AND SHOULD RETURN IN THIS ELSE STATEMENT.  SO SLEEPY RIGHT NOW.
                        let dayForecast = dailyForecastDataBlock.data[dayForecastIndex]
                        print(dayForecast.time)
                        
                        self.forecastDayDataPointArray.append(dayForecast)
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
        //print("In func setAPIKeys in WeatherAPIService...")
        
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        self.keys = NSDictionary(contentsOfFile: path)!
    }
}
