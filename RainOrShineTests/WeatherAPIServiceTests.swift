//
//  WeatherAPIServiceTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/18/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest


@testable import RainOrShine

class WeatherAPIServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    //Set the current weather forecast using a valid mock location (Washington, D.C., lat: 38.9, lon: -77.03)
    func testSetCurrentWeatherForecast() {
        let setForecastExpectation = expectation(description: "setCurrentWeatherForecast retrieves the forecast for the location and runs the callback closure")
        
        let weatherAPIService: WeatherAPIService = WeatherAPIService()
        weatherAPIService.setAPIKeys()
        weatherAPIService.setWeatherClient()
        //Regardless if the forecast comes back nil or not nil, what is important is that the completion(forecastRetrieved) was true
        weatherAPIService.setCurrentWeatherForecast(latitude: 38.9, longitude: -77.03) { (forecastRetrieved) -> () in
            if (forecastRetrieved) {
                XCTAssertTrue(forecastRetrieved)
                setForecastExpectation.fulfill()
            }
        }
        
        //Wait 5 seconds for the forecast until declaring failure
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    
    //Set the current weather forecast using an invalid mock location (Washington, D.C., lat: 38.9, lon: -77.03)
    func testSetCurrentWeatherForecastWithOutOfBoundValues() {
        
        let weatherAPIService: WeatherAPIService = WeatherAPIService()
        weatherAPIService.setAPIKeys()
        weatherAPIService.setWeatherClient()
        //Regardless if the forecast comes back nil or not nil, what is important is that the completion(forecastRetrieved) was true
        weatherAPIService.setCurrentWeatherForecast(latitude: 91, longitude: -181) { (forecastRetrieved) -> () in
            if (forecastRetrieved) {
                XCTFail("Forecast received when provided with out of range lat and lon values. No forecast should be available.")
            }
        }
        
        sleep(5)
        XCTAssert(true)
    }

    
    
    //Set the current weather forecast using a location that doesn't exist(lat: 0, lon: 0)
    func testSetCurrentWeatherForecastWithZeroValues() {
        let setForecastExpectation = expectation(description: "setCurrentWeatherForecast retrieves the forecast for the location and runs the callback closure")
        
        let weatherAPIService: WeatherAPIService = WeatherAPIService()
        weatherAPIService.setAPIKeys()
        weatherAPIService.setWeatherClient()
        //Regardless if the forecast comes back nil or not nil, what is important is that the completion(forecastRetrieved) was true
        weatherAPIService.setCurrentWeatherForecast(latitude: 0, longitude:0) { (forecastRetrieved) -> () in
            if (forecastRetrieved) {
                XCTAssertTrue(forecastRetrieved)
                setForecastExpectation.fulfill()
            }
        }
        
        //Wait 5 seconds for the forecast until declaring failure
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
