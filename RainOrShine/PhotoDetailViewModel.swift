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
    init() {
        currentPlace = Observable(LocationAPIService.currentPlace)
        currentPlaceImageIndex = Observable(LocationAPIService.currentPlaceImageIndex)
    }
    
    
    // MARK: - Methods
    func updatePlace(newPlace: Place?) {
        currentPlace.value = newPlace
    }
    
    
    func updatePlaceImageIndex(newPlaceImageIndex: Int?) {
        //print("In func updatePlaceImageIndex...")
        currentPlaceImageIndex.value = newPlaceImageIndex
    }
}
