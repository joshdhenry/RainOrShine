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
    let currentTimeZoneIdentifier: Observable<String?>
    
    
    // MARK: - Initializer
    init(forecastDataPointArray: [DataPoint]?, timeZoneIdentifier: String?) {
        currentForecastDayDataPointArray = Observable(forecastDataPointArray)
        currentTimeZoneIdentifier = Observable(timeZoneIdentifier)
    }
    
    
    // MARK: - Methods
    func updateForecastDayDataPointArray(newForecastDayDataPointArray: [DataPoint]?, newTimeZoneIdentifier: String?) {
        currentForecastDayDataPointArray.value = newForecastDayDataPointArray
        currentTimeZoneIdentifier.value = newTimeZoneIdentifier
    }
}
