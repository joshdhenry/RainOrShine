//
//  IAPHelperExtensionSKPaymentTransactionObserver.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/24/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import StoreKit

extension IAPHelper: SKPaymentTransactionObserver {
    
    // MARK: - Methods
    //Handle transactions and the response from Apple's servers
    internal func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple")
        
        for transaction: AnyObject in transactions {
            guard let currentTransaction: SKPaymentTransaction = transaction as? SKPaymentTransaction else {return}
            
            switch currentTransaction.transactionState {
            case .purchased, .restored:
                let productIdentifier = currentTransaction.payment.productIdentifier

                if (productIdentifier == Products.removeAds) {
                    currentSettings.removeAdsPurchased = true
                }
                
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                break
            case .failed:
                if (currentTransaction.error != nil) {
                    let purchaseFailureNotification = Notification.Name(rawValue:"PurchaseFailed")
                    NotificationCenter.default.post(name: purchaseFailureNotification, object: nil)
                }
                
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                break
            case .purchasing:
                break
            default:
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                break
            }
        }
    }
    
    
    //If a purchase restoration completed with error, send a notification to SettingsTableViewController to alert the user
    internal func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("Error restoring completed transactions - \(error.localizedDescription)")
        
        let purchasesRestoreFailureNotification = Notification.Name(rawValue:"PurchasesRestoreFailed")
        NotificationCenter.default.post(name: purchasesRestoreFailureNotification, object: nil)
    }
    
    
    //If a purchase restoration completed, send a notification to SettingsTableViewController to alert the user
    internal func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        let purchasesRestoredNotification = Notification.Name(rawValue:"purchasesRestored")
        NotificationCenter.default.post(name: purchasesRestoredNotification, object: nil)
    }
}
