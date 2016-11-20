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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
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
    
    
    //Test to make sure that createGestureRecognizer creates and attaches to the view in ViewController
    func testCreateGestureRecognizers() {
        
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        viewController = navigationController.topViewController as! WeatherViewController
        UIApplication.shared.keyWindow!.rootViewController = viewController
        
        var numOfGestureRecognizers: Int = 0

        if (viewController.view.gestureRecognizers != nil) {
            for recognizer in viewController.view.gestureRecognizers! {
                if let _ = recognizer as? UISwipeGestureRecognizer {
                    numOfGestureRecognizers += 1
                }
            }
        }
        
        XCTAssertEqual(numOfGestureRecognizers, 2, "Not all gesture recognizers were successfully added to ViewController...")
    }
    
    

    //Test to make sure that viewController.displayLocationSearchBar adds the subview to the view
    func testDisplayLocationSearchBar() {
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        viewController = navigationController.topViewController as! WeatherViewController
        UIApplication.shared.keyWindow!.rootViewController = viewController
        
        var searchBarFound: Bool = false
        
        for view in viewController.view.subviews {
            if (view.accessibilityIdentifier == "Location Search Bar") {
                searchBarFound = true
            }
        }
        
        XCTAssertTrue(searchBarFound, "viewController.displayLocationSearchBar did not correctly add the search bar to the view...")
    }
    
    
    //Test the color scheme structs computed var by getting the light gray color and assuring it returns the correct UIColor
    func testColorSchemeComputedVar() {
        let lightGrayColor = ColorScheme.lightGray
        
        XCTAssertTrue(lightGrayColor == UIColor(netHex: 0xf9f9f9), "ColorScheme's computed color vars are not returning the correct value...")
    }
    
    
    //Rotate the main screen to landscape and check that the locationSearchView resized its width correctly
    func testLandscapeLocationSearchView() {
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        viewController = navigationController.topViewController as! WeatherViewController
        UIApplication.shared.keyWindow!.rootViewController = viewController

        XCUIDevice.shared().orientation = .landscapeRight
        viewController.resizeLocationSearchView(orientationAfterRotation: .landscapeRight)
        
        let locationSearchViewWidth = viewController.locationSearchView.searchController?.searchBar.frame.size.width
        let screenHeight = viewController.screenWidthAndHeight.height
        
        XCTAssert(locationSearchViewWidth == screenHeight, "locationSearchViewWidth did not resize correctly after switching to landscape mode.")
    }
    
    
    //Rotate the main screen to landscape then back to portrait and check that the locationSearchView resized its width correctly
    func testPortraitLocationSearchView() {
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        viewController = navigationController.topViewController as! WeatherViewController
        UIApplication.shared.keyWindow!.rootViewController = viewController
        
        XCUIDevice.shared().orientation = .landscapeRight
        viewController.resizeLocationSearchView(orientationAfterRotation: .landscapeRight)
        
        XCUIDevice.shared().orientation = .portrait
        viewController.resizeLocationSearchView(orientationAfterRotation: .portrait)
        
        let locationSearchViewWidth = viewController.locationSearchView.searchController?.searchBar.frame.size.width
        let screenWidth = viewController.screenWidthAndHeight.width
        
        XCTAssert(locationSearchViewWidth == screenWidth, "locationSearchViewWidth did not resize correctly after going from portrait to landscape then back to portrait again.")
    }
}
