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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            /*print("RUNNING....")
            LocationAPIService.setCurrentExactPlace() { (isLocationFound, locationPlace) -> () in
                if(isLocationFound) {
                    print("Set the exact place...")
                }
            }*/
        }
    }
    
    
    func testCurrentWeatherViewModelUpdateForecast() {
        
        let jsonString: String = "{\"latitude\":12,\"longitude\":12,\"timezone\":\"Etc/GMT\",\"offset\":0}"
        let jsonDictionary = jsonString.convertStringToDictionary()
        
        if jsonDictionary != nil {
            let forecast = Forecast(fromJSON: jsonDictionary as! NSDictionary)
            let currentWeatherViewModel: CurrentWeatherViewModel = CurrentWeatherViewModel(forecast: forecast)
            
            currentWeatherViewModel.updateForecast(newForecast: forecast)
            
            XCTAssertEqual(currentWeatherViewModel.currentForecast.value?.latitude, forecast.latitude, "currentWeatherViewModel.updateForecast did not correctly update currentWeatherViewModel.currentForecast...")
        }
        //Else the jsonDictionary is nil.  Fail to indicate we have a problem
        else {
            XCTAssert(false)
        }
    }
    
    
    //Test the updatePlace method by calling it with an argument of a place with a test image.  If the value changes in the view model, the updatePlace works correctly.
    func testLocationViewModelUpdatePlace() {
        let locationViewModel: LocationViewModel = LocationViewModel(place: nil)
        
        let newPlace: Place = Place()
        let testImage = UIImage(named: "TestImage")
        newPlace.generalLocalePhotoArray.append(testImage)
        
        locationViewModel.updateGeneralLocalePlace(newPlace: newPlace)
        
        XCTAssertEqual(locationViewModel.currentGeneralLocalePlace.value?.generalLocalePhotoArray[0], newPlace.generalLocalePhotoArray[0], "locationViewModel.updatePlace did not correctly update locationViewModel.currentPlace...")
    }
    
    
    func testPhotoDetailViewModelUpdatePlaceImageIndex() {
        let photoDetailViewModel: PhotoDetailViewModel = PhotoDetailViewModel(place: nil, imageIndex: nil)
        
        let newPlaceImageIndex = 123
        
        photoDetailViewModel.updatePlaceImageIndex(newPlaceImageIndex: newPlaceImageIndex, place: nil)
        
        XCTAssertEqual(photoDetailViewModel.currentPlaceImageIndex.value, newPlaceImageIndex, "photoDetailViewModel.updatePlaceImageIndex did not correctly update photoDetailViewModel.currentPlaceImageIndex...")
    }
    
    
    //Test to make sure that createGestureRecognizer creates and attaches to the view in ViewController
    /*func testCreateGestureRecognizers() {
        let viewController = WeatherViewController()
        print("A")
        
        var numOfGestureRecognizers: Int = 0
        print("B")
        print(viewController.view.gestureRecognizers)
        print("BB")
        if (viewController.view.gestureRecognizers != nil) {
            print("C")

            for recognizer in viewController.view.gestureRecognizers! {
                print("D")

                if let _ = recognizer as? UISwipeGestureRecognizer {
                    print("E")

                    numOfGestureRecognizers += 1
                }
            }
        }
        
        XCTAssertEqual(numOfGestureRecognizers, 2, "Not all gesture recognizers were successfully added to ViewController...")
    }*/
    
    
    //SHOULD THIS BE IN UI TESTS?
    //Test to make sure that viewController.displayLocationSearchBar adds the subview to the view
    func testDisplayLocationSearchBar() {
        /*let viewController = WeatherViewController()
        var searchBarFound: Bool = false
        
        for view in viewController.view.subviews {
            if (view.accessibilityIdentifier == "Location Search Bar") {
                searchBarFound = true
            }
        }
        
        XCTAssertTrue(searchBarFound, "viewController.displayLocationSearchBar did not correctly add the search bar to the view...")*/
    }
    
    func testColorSchemeComputedVar() {
        let lightGrayColor = ColorScheme.lightGray
        
        XCTAssertTrue(lightGrayColor == UIColor(netHex: 0xf9f9f9), "ColorScheme's computed color vars are not returning the correct value...")
    }
}
