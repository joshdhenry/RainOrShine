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
    let currentForecast: Observable<Forecast?>
    
    
    init() {
        self.currentForecast = Observable(WeatherAPIService.currentWeatherForecast)
    }
    
    
    func updateForecast(newForecast: Forecast?) {
        //print("In func updateForecast...")
        currentForecast.value = newForecast
    }
}
