//
//  SettingsTableViewControllerExtensionPurchaseUpdatesObserver.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

extension SettingsTableViewController: PurchaseUpdatesObserver {
    
    // MARK: - Methods

    //Create the observers to catch notifications sent from Settings Detail Table View Controller
    internal func createPurchaseUpdatesObservers() {
        NotificationCenter.default.addObserver(forName: purchasesRestoredNotification, object: nil, queue: nil, using: catchPurchasesRestoredNotification)
        NotificationCenter.default.addObserver(forName: purchasesRestoreFailureNotification, object: nil, queue: nil, using: catchPurchasesRestoreFailureNotification)
        NotificationCenter.default.addObserver(forName: purchaseFailureNotification, object: nil, queue: nil, using: catchPurchaseFailureNotification)
    }

    
    // MARK: Methods to catch IAP notifications
    //Catch purchases restored notification center notifications
    internal func catchPurchasesRestoredNotification(notification:Notification) -> Void {
        displaySimpleAlert(title: "Purchases Restored", message: "Any prior purchases you have made have now been restored to this device.", buttonText: "OK")
    }
    
    
    //Catch restore purchases failure notification center notifications
    internal func catchPurchasesRestoreFailureNotification(notification:Notification) -> Void {
        displaySimpleAlert(title: "Purchase Restore Failed", message: "There was a problem restoring prior purchases.", buttonText: "OK")
    }
    
    
    //Catch purchase failure notification center notifications
    internal func catchPurchaseFailureNotification(notification:Notification) -> Void {
        displaySimpleAlert(title: "Purchase Failed", message: "There was a problem making the purchase. Please try again.", buttonText: "OK")
    }
}
