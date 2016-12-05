//
//  AppLogoImageViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/4/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

struct AppLogoImageViewModel {
    
    // MARK: - Properties
    let currentPlaceImageIndex: Observable<Int?>
    let currentGeneralLocalePlace: Observable<Place?>
    
    
    // MARK: - Initializer
    init(placeImageIndex: Int?, place: Place?) {
        currentPlaceImageIndex = Observable(placeImageIndex)
        currentGeneralLocalePlace = Observable(place)
    }
    
    // MARK: - Methods
    func updatePlaceImageIndex(newPlaceImageIndex: Int?, place: Place?) {
        currentGeneralLocalePlace.value = place
        currentPlaceImageIndex.value = newPlaceImageIndex
    }
}
