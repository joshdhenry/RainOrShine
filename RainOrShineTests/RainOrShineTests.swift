//
//  RainOrShineTests.swift
//  RainOrShineTests
//
//  Created by Josh Henry on 10/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest
import CoreLocation
import UIKit

@testable import RainOrShine

class RainOrShineTests: XCTestCase, CLLocationManagerDelegate {
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        //let locationManager = CLLocationManager()
        //locationManager.delegate = self
        //locationManager.requestWhenInUseAuthorization()
        
    }
    
    /*
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization Status Changed to \(status.rawValue)")
        switch status {
        case .authorized, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            locationManager.stopUpdatingLocation()
        }
    }*/
    
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
    
    
    
    func testsetCurrentLocationPlace() {
        
                
        
        //LocationAPIService.setAPIKeys()
        
        //LocationAPIService.setCurrentLocationPlace() { (locationFindComplete) -> () in
            //if (locationFindComplete == true) {
                //XCTAssertTrue(locationFindComplete, "LocationAPIService.testsetCurrentLocationPlace never completed.")
            
            //}
        //}
    }
 
    
    /*
    func testSetPhotoOfGeneralLocale() {
        locationAPIService?.setCurrentLocationPlace() { (locationFound) -> () in
            if (locationFound == true) {
                let place = self.locationAPIService?.currentPlace
                
                
            }
        }
    }*/
    
    /*
    func testA() {
        let vc = ViewController()
        
        var locationAPIService: LocationAPIService?
        LocationAPIService.setAPIKeys()
        locationAPIService = LocationAPIService()
        
        locationAPIService?.setCurrentLocationPlace() { (isLocationFound, locationPlace) -> () in
            if (isLocationFound == true) {
                vc.changePlace(place: locationPlace)
            }
        }
    }
 */
    
  /*
    func testWeatherViewModel() {
        let viewController = UIViewController() as! ViewController
        
        LocationAPIService.setCurrentLocationPlace() { (currentLocationFound) -> () in
            if (currentLocationFound) {
                
                let originalValue = LocationAPIService.currentPlace
                
                print("originalValue - should be nil - It is \(originalValue)")

                
                let place = LocationAPIService.currentPlace
                
                
                viewController.viewModel?.updatePlace(newPlace: place)
                
                let newValue = LocationAPIService.currentPlace
                print("newValue - should not be nil - It is \(newValue)")

                XCTAssert(newValue != nil)
            }
        }
    }
    */
    
}
