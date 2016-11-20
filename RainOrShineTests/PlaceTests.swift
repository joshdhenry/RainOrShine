//
//  PlaceTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/17/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest
import GooglePlaces

@testable import RainOrShine

class PlaceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //DOESNT WORK
    func testGetGeneralLocaleString() {
        /*let addressComponent = MockGMSAddressComponent()
        
        var addressComponentArray: [MockGMSAddressComponent] = [MockGMSAddressComponent]()
        
        
        addressComponent.type = "street_number"
        addressComponent.name = "602"
        
        addressComponentArray.append(addressComponent)
        
        addressComponent.type = "route"
        addressComponent.name = "Galer Street"
        
        addressComponentArray.append(addressComponent)
        
        addressComponent.type = "neighborhood"
        addressComponent.name = "East Queen Anne"
        
        addressComponentArray.append(addressComponent)
        
        addressComponent.type = "locality"
        addressComponent.name = "Seattle"
        
        addressComponentArray.append(addressComponent)
        
        addressComponent.type = "administrative_area_level_2"
        addressComponent.name = "King County"
        
        addressComponentArray.append(addressComponent)
        
        addressComponent.type = "administrative_area_level_1"
        addressComponent.name = "Washington"
        
        addressComponentArray.append(addressComponent)
        
        addressComponent.type = "country"
        addressComponent.name = "United States"
        
        addressComponentArray.append(addressComponent)
        
        addressComponent.type = "postal_code"
        addressComponent.name = "98109"
        
        addressComponentArray.append(addressComponent)
        
        addressComponent.type = "postal_code_suffix"
        addressComponent.name = "3382"
        
        addressComponentArray.append(addressComponent)

        print("AAA")
        let mockGMSPlace: MockGMSPlace = MockGMSPlace()
        print("BBB")

        mockGMSPlace.addressComponents = addressComponentArray
        
        let mockPlace: Place = Place(place: mockGMSPlace)
        let generalLocaleString = mockPlace.getGeneralLocaleString()
        print("generalLocaleString is \(generalLocaleString)")
        
        XCTAssert(generalLocaleString == "Seattle+Washington+United+States", "Yada")*/
    }
}

 
 public class MockGMSAddressComponent: GMSAddressComponent {
    
    var typeText = ""
    var nameText = ""
    
    override open var type: String {
        get {
            return typeText
        }
        set {
            self.typeText = newValue
        }
    }
    
    override open var name: String {
        get {
            return nameText
        }
        set {
            self.nameText = newValue
        }
    }
}

public class MockGMSPlace: GMSPlace {
    var addressComponentsArray: [GMSAddressComponent]? = [GMSAddressComponent]()
    
    override open var addressComponents: [GMSAddressComponent]? {
        get {
            return addressComponentsArray
        }
        set {
            self.addressComponentsArray = newValue as! [MockGMSAddressComponent]?
        }
    }
}
