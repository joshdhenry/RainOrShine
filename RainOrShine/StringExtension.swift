//
//  StringExtension.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/7/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

extension String {
    
    // MARK: - Computed Property
    var intFromPlainEnglish: Int {
        get {
            switch (self) {
            case "1 Minute":
                return 1
            case "3 Minutes":
                return 3
            case "5 Minutes":
                return 5
            case "15 Minutes":
                return 15
            case "30 Minutes":
                return 30
            case "60 Minutes":
                return 60
            default:
                return 0
            }
        }
    }
    
    // MARK: - Method

    //This function is used by testUpdateForecast to create a mock JSON from a string
    func convertStringToDictionary() -> [String:AnyObject]? {
        guard let data = self.data(using: String.Encoding.utf8) else {return nil}
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            print("Error converting string to dictionary - \(error)")
            return nil
        }
    }
}
