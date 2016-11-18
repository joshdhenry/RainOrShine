//
//  CurrentWeatherViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import ForecastIO

struct CurrentWeatherViewModel {
    // MARK: - Properties
    let currentForecast: Observable<Forecast?>

    
    // MARK: - Initializer
    init(forecast: Forecast?) {
        currentForecast = Observable(forecast)
    }
    
    
    // MARK: - Methods
    func updateForecast(newForecast: Forecast?) {
        //print("In func updateForecast...")
        currentForecast.value = newForecast
    }
}
