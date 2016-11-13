//
//  PhotoDetailViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

class PhotoDetailViewModel {
    let currentPlace: Observable<Place?>
    
    init() {
        currentPlace = Observable(LocationAPIService.currentPlace)
    }
    
    
    func updatePlace(newPlace: Place?) {
        currentPlace.value = newPlace
    }
}
