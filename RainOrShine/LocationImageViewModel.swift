//
//  LocationImageViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

struct LocationImageViewModel {
    // MARK: - Properties
    let currentPlaceImageIndex: Observable<Int?>
    let currentPlace: Observable<Place?>

    
    // MARK: - Initializer
    init(placeImageIndex: Int?, place: Place?) {
        currentPlaceImageIndex = Observable(placeImageIndex)
        currentPlace = Observable(place)
    }
    
    // MARK: - Methods
    func updatePlaceImageIndex(newPlaceImageIndex: Int?, place: Place?) {
        //print("In func updatePlaceImageIndex...")
        currentPlaceImageIndex.value = newPlaceImageIndex
        
        currentPlace.value = place
    }
}
