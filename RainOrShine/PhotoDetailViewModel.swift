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
    let currentPlace: Observable<Place?>
    let currentPlaceImageIndex: Observable<Int?>

    
    // MARK: - Initializer
    init(place: Place?, imageIndex: Int?) {
        currentPlace = Observable(place)
        currentPlaceImageIndex = Observable(imageIndex)
    }
    
    
    // MARK: - Methods
    func updatePlace(newPlace: Place?) {
        currentPlace.value = newPlace
    }
    
    
    func updatePlaceImageIndex(newPlaceImageIndex: Int?, place: Place?) {
        //print("In func updatePlaceImageIndex...")
        currentPlaceImageIndex.value = newPlaceImageIndex
        
        currentPlace.value = place
    }
}
