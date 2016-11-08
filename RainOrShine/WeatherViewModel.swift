//
//  weatherViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/31/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import ForecastIO

class WeatherViewModel {
    let currentPlace: Observable<Place?>
    let currentForecast: Observable<Forecast?>
    let currentPlaceImageIndex: Observable<Int?>
    //let blur: Observable<UIBlurEffectStyle?>
    
    
    init() {
        self.currentPlace = Observable(LocationAPIService.currentPlace)
        self.currentForecast = Observable(WeatherAPIService.currentWeatherForecast)        
        self.currentPlaceImageIndex = Observable(LocationAPIService.currentPlaceImageIndex)
        //self.blur = Observable(Style.blur)
    }
    
    
    func updateForecast(newForecast: Forecast?) {
        print("In func updateForecast...")
        currentForecast.value = newForecast
    }
    
    
    func updatePlace(newPlace: Place?) {
        print("In func updatePlace...")
        currentPlace.value = newPlace
    }
    
    
    func updatePlaceImageIndex(newPlaceImageIndex: Int?) {
        print("In func updatePlaceImageIndex...")
        currentPlaceImageIndex.value = newPlaceImageIndex
    }
    
    
    /*func updateBlurStyle(blurStyle: UIBlurEffectStyle?) {
        blur.value = blurStyle
    }*/
}
