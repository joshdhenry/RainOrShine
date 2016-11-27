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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testUpdatePlace() {
        
    }
    
    
    //Test the updatePlaceImageIndex() method of photoDetailViewModel by setting an index of 123 and verifying that the view model altered the view
    func testUpdatePlaceImageIndex() {
        let photoDetailViewModel: PhotoDetailViewModel = PhotoDetailViewModel(place: nil, imageIndex: nil)
        
        let newPlaceImageIndex = 123
        
        photoDetailViewModel.updatePlaceImageIndex(newPlaceImageIndex: newPlaceImageIndex, place: nil)
        
        XCTAssertEqual(photoDetailViewModel.currentPlaceImageIndex.value, newPlaceImageIndex, "photoDetailViewModel.updatePlaceImageIndex did not correctly update photoDetailViewModel.currentPlaceImageIndex...")
    }
    
}
