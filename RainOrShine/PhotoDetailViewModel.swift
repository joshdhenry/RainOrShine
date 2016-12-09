//
//  PhotoDetailViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

struct PhotoDetailViewModel {
    
    // MARK: - Properties
    let currentGeneralLocalePlace: Observable<Place?>
    let currentPlaceImageIndex: Observable<Int?>

    
    // MARK: - Initializer
    init(place: Place?, imageIndex: Int?) {
        currentGeneralLocalePlace = Observable(place)
        currentPlaceImageIndex = Observable(imageIndex)
    }
    
    
    // MARK: - Methods
    func updatePlace(newPlace: Place?) {
        currentGeneralLocalePlace.value = newPlace
    }
    
    
    func updatePlaceImageIndex(newPlaceImageIndex: Int?, place: Place?) {
        currentGeneralLocalePlace.value = place
        currentPlaceImageIndex.value = newPlaceImageIndex
    }
}
