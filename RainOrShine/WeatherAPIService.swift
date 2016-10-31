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
    static var keys: NSDictionary = NSDictionary()

    var weatherClient: DarkSkyClient?
    
    
    init() {
        initializeWeatherClient()
    }
    
    
    private func initializeWeatherClient() {
        weatherClient = DarkSkyClient(apiKey: WeatherAPIService.keys["DarkSkyAPIKey"] as! String)
    }
    
    
    public func getCurrentWeatherForecast(latitude: Double, longitude: Double) {
        weatherClient?.getForecast(latitude: latitude, longitude: longitude) { (result) in
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
                    print("time is \(hourlyForecast.time)")
                    print("precipitation probability is \(hourlyForecast.precipitationProbability)")
                    print("precipitation type is \(hourlyForecast.precipitationType)")
                    print("wind speed is \(hourlyForecast.windSpeed)")
                    print("summary is \(hourlyForecast.summary)")
                    print("-----")
                }*/
                print("Hi.")
            case .failure(let error):
                print("Error retrieving current weather forecast - \(error)")
            }
        }
    }
    
    
    //Load the Dark Sky API keys from APIKeys.plist
    static public func setAPIKeys() {
    guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        WeatherAPIService.keys = NSDictionary(contentsOfFile: path)!
    }
}
