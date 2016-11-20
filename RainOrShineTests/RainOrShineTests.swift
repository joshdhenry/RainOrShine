//
//  RainOrShineTests.swift
//  RainOrShineTests
//
//  Created by Josh Henry on 10/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest
import ForecastIO
import CoreLocation

@testable import RainOrShine

class RainOrShineTests: XCTestCase, CLLocationManagerDelegate {
    
    var viewController: WeatherViewController!
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    //Test retrieving the current forecast with a mock location and make sure it returns a value.
    //The dummy value is the coordinates of Yobe, Nigeria
    func testCurrentWeatherViewModelUpdateForecast() {
        let jsonString: String = "{\"latitude\":12,\"longitude\":12,\"timezone\":\"Etc/GMT\",\"offset\":0}"
        let jsonDictionary = jsonString.convertStringToDictionary()
        
        if jsonDictionary != nil {
            let forecast = Forecast(fromJSON: jsonDictionary as! NSDictionary)
            let currentWeatherViewModel: CurrentWeatherViewModel = CurrentWeatherViewModel(forecast: forecast)
            
            currentWeatherViewModel.updateForecast(newForecast: forecast)
            
            XCTAssertEqual(currentWeatherViewModel.currentForecast.value?.latitude, forecast.latitude, "currentWeatherViewModel.updateForecast did not correctly update currentWeatherViewModel.currentForecast...")
        }
        //Else the jsonDictionary is nil.  Fail the test.
        else {
            XCTAssert(false)
        }
    }
    
    
    //Test the updatePlace method by calling it with an argument of a place with a test image.  If the value changes in the view model, the updatePlace works correctly.
    func testLocationViewModelUpdatePlace() {
        let locationViewModel: LocationViewModel = LocationViewModel(place: nil)
        
        let newPlace: Place = Place()
        let testImage = UIImage(named: "TestImage")
        newPlace.photoArray.append(testImage)
        
        locationViewModel.updateGeneralLocalePlace(newPlace: newPlace)
        
        XCTAssertEqual(locationViewModel.currentGeneralLocalePlace.value?.photoArray[0], newPlace.photoArray[0], "locationViewModel.updatePlace did not correctly update locationViewModel.currentPlace...")
    }
    
    
    //Test the updatePlaceImageIndex() method of photoDetailViewModel by setting an index of 123 and verifying that the view model altered the view
    func testPhotoDetailViewModelUpdatePlaceImageIndex() {
        let photoDetailViewModel: PhotoDetailViewModel = PhotoDetailViewModel(place: nil, imageIndex: nil)
        
        let newPlaceImageIndex = 123
        
        photoDetailViewModel.updatePlaceImageIndex(newPlaceImageIndex: newPlaceImageIndex, place: nil)
        
        XCTAssertEqual(photoDetailViewModel.currentPlaceImageIndex.value, newPlaceImageIndex, "photoDetailViewModel.updatePlaceImageIndex did not correctly update photoDetailViewModel.currentPlaceImageIndex...")
    }
}
