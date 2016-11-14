//
//  CurrentWeatherViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import ForecastIO

class CurrentWeatherViewModel {
    // MARK: - Properties
    let currentForecast: Observable<Forecast?>

    
    // MARK: - Initializer
    init() {
        currentForecast = Observable(WeatherAPIService.currentWeatherForecast)
    }
    
    
    // MARK: - Methods
    func updateForecast(newForecast: Forecast?) {
        //print("In func updateForecast...")
        currentForecast.value = newForecast
    }
}
