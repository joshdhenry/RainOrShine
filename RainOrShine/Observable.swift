//
//  Observable.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/31/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

class Observable<T> {
    typealias Observer = (T) -> Void
    var observer: Observer?
    
    func observe(observer: Observer?) {
        self.observer = observer
        observer?(value)
    }
    
    //If the value was set, run the observer function
    var value: T {
        didSet {
            observer?(value)
        }
    }
    
    //Call didSet when value is initiated
    init(_ value: T) {
        self.value = value
    }
}
