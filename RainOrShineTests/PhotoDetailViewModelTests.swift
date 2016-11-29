//
//  PhotoDetailViewModelTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class PhotoDetailViewModelTests: XCTestCase {
    
    let photoDetailViewModel: PhotoDetailViewModel = PhotoDetailViewModel(place: nil, imageIndex: nil)
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testUpdatePlace() {
        photoDetailViewModel.updatePlace(newPlace: Place())
        
        XCTAssert(photoDetailViewModel.currentGeneralLocalePlace.value != nil, "photoDetailViewModel.updatePlace did not correctly update photoDetailViewModel.currentGeneralLocalePlace...")
    }
    
    
    func testUpdatePlaceWithNil() {
        photoDetailViewModel.updatePlace(newPlace: nil)
        
        XCTAssert(photoDetailViewModel.currentGeneralLocalePlace.value == nil, "photoDetailViewModel.updatePlace did not correctly update photoDetailViewModel.currentGeneralLocalePlace when passed a nil value.")
    }
    
    
    //Test the updatePlaceImageIndex() method of photoDetailViewModel by setting an index of 123 and verifying that the view model altered the view
    func testUpdatePlaceImageIndex() {
        photoDetailViewModel.updatePlaceImageIndex(newPlaceImageIndex: 123, place: Place())
        
        XCTAssert(photoDetailViewModel.currentPlaceImageIndex.value == 123 &&
                  photoDetailViewModel.currentGeneralLocalePlace.value != nil,
                  "photoDetailViewModel.updatePlaceImageIndex did not correctly update photoDetailViewModel.currentPlaceImageIndex...")
    }
    
    
    //Test the updatePlaceImageIndex() method of photoDetailViewModel by setting an index of nil and verifying that the view model altered the view
    func testUpdatePlaceImageIndexWithNil() {
        photoDetailViewModel.updatePlaceImageIndex(newPlaceImageIndex: nil, place: nil)
        
        XCTAssert(photoDetailViewModel.currentPlaceImageIndex.value == nil &&
                  photoDetailViewModel.currentGeneralLocalePlace.value == nil,
                  "photoDetailViewModel.updatePlaceImageIndex did not correctly update photoDetailViewModel.currentPlaceImageIndex when passed nil values.")
    }
}
