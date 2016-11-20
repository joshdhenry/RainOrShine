//
//  WeatherViewControllerTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/19/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class WeatherViewControllerTests: XCTestCase {
    
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
    
    
    //TODO:- Finish writing this test
    //Start the app in landscape and ensure the location search view sizes correctly.
    func testStartInLandscapeLocationSearchView() {
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        viewController = navigationController.topViewController as! WeatherViewController
        UIApplication.shared.keyWindow!.rootViewController = viewController
    }
}
