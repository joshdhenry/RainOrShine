//
//  FutureWeatherViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import ForecastIO

struct FutureWeatherViewModel {
    // MARK: - Properties
    let currentForecastDayDataPointArray: Observable<[DataPoint]?>
    
    
    // MARK: - Initializer
    init(forecastDataPointArray: [DataPoint]?) {
        currentForecastDayDataPointArray = Observable(forecastDataPointArray)
    }
    
    
    // MARK: - Methods
    func updateForecastDayDataPointArray(newForecastDayDataPointArray: [DataPoint]?) {
        //print("In func updateForecastDayDataPointArray...")
        currentForecastDayDataPointArray.value = newForecastDayDataPointArray
    }
}
