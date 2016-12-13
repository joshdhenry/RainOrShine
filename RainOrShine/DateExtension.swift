//
//  DateExtension.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/9/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

extension Date {

    // MARK: - Methods
    //Return the abbreviated day (ex: Mon, Tue, Wed, etc)
    func getAbbreviatedDayString(timeZoneIdentifier: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        
        NSLog("Time zone -\(dateFormatter.timeZone)")
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        NSLog(dateFormatter.string(from: self))
        
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self)
    }
}
