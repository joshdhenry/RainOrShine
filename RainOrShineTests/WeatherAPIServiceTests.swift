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
    
    
    //Set the current weather forecast using a mock location (Washington, D.C., lat: 38.9, lon: -77.03)
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
}
