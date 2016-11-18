//
//  LocationViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/12/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

struct LocationViewModel {
    let currentGeneralLocalePlace: Observable<Place?>

    init() {
        currentGeneralLocalePlace = Observable(LocationAPIService.generalLocalePlace)
    }
    
    
    func updateGeneralLocalePlace(newPlace: Place?) {
        currentGeneralLocalePlace.value = newPlace
    }
}
