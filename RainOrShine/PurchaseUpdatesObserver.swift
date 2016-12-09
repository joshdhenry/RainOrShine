//
//  PurchaseUpdatesObserver.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

protocol PurchaseUpdatesObserver {
    
    // MARK: - Required Methods
    func createPurchaseUpdatesObservers()
    func catchPurchasesRestoredNotification(notification:Notification) -> Void
    func catchPurchasesRestoreFailureNotification(notification:Notification) -> Void
    func catchPurchaseFailureNotification(notification:Notification) -> Void
}
