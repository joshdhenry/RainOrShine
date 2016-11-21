//
//  LocationViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/12/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

struct LocationViewModel {
    // MARK: - Properties
    let currentGeneralLocalePlace: Observable<Place?>

    
    // MARK: - Initializer
    init(place: Place?) {
        currentGeneralLocalePlace = Observable(place)
    }
    
    
    // MARK: - Methods
    func updateGeneralLocalePlace(newPlace: Place?) {
        currentGeneralLocalePlace.value = newPlace
    }
}
