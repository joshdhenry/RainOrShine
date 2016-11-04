//
//  RainOrShineTests.swift
//  RainOrShineTests
//
//  Created by Josh Henry on 10/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest
import GooglePlaces
import ForecastIO

@testable import RainOrShine

class RainOrShineTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func testUpdateForecast() {
        let weatherViewModel: WeatherViewModel = WeatherViewModel()
        let jsonString: String = "{\"latitude\":12,\"longitude\":12,\"timezone\":\"Etc/GMT\",\"offset\":0}"
        let jsonDictionary = convertStringToDictionary(text: jsonString)
        
        if jsonDictionary != nil {
            let forecast = Forecast(fromJSON: jsonDictionary as! NSDictionary)
            
            weatherViewModel.updateForecast(newForecast: forecast)
            
            XCTAssertEqual(weatherViewModel.currentForecast.value?.latitude, forecast.latitude, "weatherViewModel.updateForecast did not correctly update weatherViewModel.currentForecast...")
        }
        //Else the jsonDictionary is nil.  Fail to indicate we have a problem
        else {
            XCTAssert(false)
        }
    }
    
    
    //This function is used by testUpdateForecast to create a mock JSON from a string
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    
    //Test the updatePlace method by calling it with an argument of a place with a test image.  If the value changes in the view model, the updatePlace works correctly.
    func testUpdatePlace() {
        let weatherViewModel: WeatherViewModel = WeatherViewModel()
        
        let newPlace: Place = Place()
        let testImage = UIImage(named: "TestImage")
        newPlace.generalLocalePhotoArray.append(testImage)
        
        weatherViewModel.updatePlace(newPlace: newPlace)
        
        XCTAssertEqual(weatherViewModel.currentPlace.value?.generalLocalePhotoArray[0], newPlace.generalLocalePhotoArray[0], "weatherViewModel.updatePlace did not correctly update weatherViewModel.currentPlace...")
    }
    
    
    func testUpdatePlaceImageIndex() {
        let weatherViewModel: WeatherViewModel = WeatherViewModel()
        
        let newPlaceImageIndex = 123
        
        weatherViewModel.updatePlaceImageIndex(newPlaceImageIndex: newPlaceImageIndex)
        
        XCTAssertEqual(weatherViewModel.currentPlaceImageIndex.value, newPlaceImageIndex, "weatherViewModel.updatePlaceImageIndex did not correctly update weatherViewModel.currentPlaceImageIndex...")
    }
    
    
    //Test to make sure that createGestureRecognizer creates and attaches to the view in ViewController
    func testCreateGestureRecognizers() {
        let viewController = ViewController()
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
    }
    
    
    //SHOULD THIS BE IN UI TESTS?
    //Test to make sure that viewController.displayLocationSearchBar adds the subview to the view
    func testDisplayLocationSearchBar() {
        let viewController = ViewController()
        var searchBarFound: Bool = false
        
        for view in viewController.view.subviews {
            if (view.accessibilityIdentifier == "Location Search Bar") {
                searchBarFound = true
            }
        }
        
        XCTAssertTrue(searchBarFound, "viewController.displayLocationSearchBar did not correctly add the search bar to the view...")
    }
    
}
