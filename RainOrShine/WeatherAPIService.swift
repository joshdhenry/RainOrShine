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
        print("In func setCurrentWeatherForecast...")
        WeatherAPIService.weatherClient?.getForecast(latitude: latitude, longitude: longitude) { (result) in
            print("Retrieved forecast from server...")
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
                print("JDFHJGHJDGHJKGDKGKDNG")
                print(currentForecast.daily?.data)
                
                //THIS IS JUST A TEMPORARY ELSE.  NOT SURE IF I SHOULD RETURN SO DEFINITELY CHECK BEFORE YOU LEAVE IT
                guard let dailyForecastDataBlock = currentForecast.daily else {return}
                
                print(dailyForecastDataBlock.summary)
                
                
                //for dayForecast in dailyForecastDataBlock.data {
                //Loop through 5 days of data
                for dayForecastIndex in 0..<5 {
                    if (dayForecastIndex < dailyForecastDataBlock.data.count) {
                        //DOUBLE CHECK IF I CAN AND SHOULD RETURN IN THIS ELSE STATEMENT.  SO SLEEPY RIGHT NOW.
                        let dayForecast = dailyForecastDataBlock.data[dayForecastIndex]
                        print(dayForecast.temperature)
                        print(dayForecast.summary)
                        print(dayForecast.temperatureMax)
                        print(dayForecast.temperatureMin)
                        print(dayForecast.time)
                        print("-----")
                        
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
