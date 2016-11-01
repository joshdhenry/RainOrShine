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
    
    
    init() {
        WeatherAPIService.weatherClient = DarkSkyClient(apiKey: WeatherAPIService.keys["DarkSkyAPIKey"] as! String)
    }
    
    
    class public func getCurrentWeatherForecast(latitude: Double, longitude: Double, completion: @escaping (_ result: Bool) ->()) {
        WeatherAPIService.weatherClient?.getForecast(latitude: latitude, longitude: longitude) { (result) in
            switch result {
            case .success(let currentForecast, let requestMetadata):
                /*print("currentForecast is \(currentForecast)")
                print("requestMetadata is \(requestMetadata)")
                
                print(currentForecast.currently?.time)
                print(currentForecast.currently?.temperature)
                print(currentForecast.currently?.icon)
                print(currentForecast.currently?.summary)
                //print(currentForecast.hourly)
                
                for hourlyForecast in (currentForecast.hourly?.data)! {
                    print("tim e is \(hourlyForecast.time)")
                    print("precipitation probability is \(hourlyForecast.precipitationProbability)")
                    print("precipitation type is \(hourlyForecast.precipitationType)")
                    print("wind speed is \(hourlyForecast.windSpeed)")
                    print("summary is \(hourlyForecast.summary)")
                    print("-----")
                }*/
                print(currentForecast.currently?.temperature)
                
                WeatherAPIService.currentWeatherForecast = currentForecast
            case .failure(let error):
                print("Error retrieving current weather forecast - \(error)")
            }
            completion(true)
            print("getCurrentWeatherForecast completed...")
        }
    }
    
    
    //Load the Dark Sky API keys from APIKeys.plist
    class public func setAPIKeys() {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        WeatherAPIService.keys = NSDictionary(contentsOfFile: path)!
    }
}
