//
//  FutureWeatherViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import ForecastIO

class FutureWeatherViewModel {
    // MARK: - Properties
    let currentForecast: Observable<Forecast?>
    
    
    // MARK: - Initializer
    init() {
        self.currentForecast = Observable(WeatherAPIService.currentWeatherForecast)
    }
    
    
    // MARK: - Methods
    func updateForecast(newForecast: Forecast?) {
        //print("In func updateForecast...")
        currentForecast.value = newForecast
    }
}
