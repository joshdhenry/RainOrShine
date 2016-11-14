//
//  LocationImageViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

class LocationImageViewModel {
    // MARK: - Properties
    let currentPlaceImageIndex: Observable<Int?>
    
    // MARK: - Initializer
    init() {
        currentPlaceImageIndex = Observable(LocationAPIService.currentPlaceImageIndex)
    }
    
    // MARK: - Methods
    func updatePlaceImageIndex(newPlaceImageIndex: Int?) {
        //print("In func updatePlaceImageIndex...")
        currentPlaceImageIndex.value = newPlaceImageIndex
    }
}
