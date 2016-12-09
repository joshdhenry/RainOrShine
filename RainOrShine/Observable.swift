//
//  Observable.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/31/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

//The Observable class is a wrapper for variables that is useful changing a view model whenever the observed variable is set or modified.
class Observable<T> {

    // MARK: - Properties
    typealias Observer = (T) -> Void
    var observer: Observer?
    
    //If the value was set, run the observer function
    var value: T {
        didSet {
            observer?(value)
        }
    }
    
    
    // MARK: - Initializer
    //Call didSet when value is initiated
    init(_ value: T) {
        self.value = value
    }
    
    
    // MARK: - Method
    //This is run when the value is set. It wraps the value with an observer.
    func observe(observer: Observer?) {
        self.observer = observer
        observer?(value)
    }
}
