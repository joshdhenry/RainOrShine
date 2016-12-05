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
            case .purchasing:
                print("Purchasing item...")
            case .purchased, .restored:
                print("Product Purchased or Restored...")
                guard let productIdentifier = currentTransaction.original?.payment.productIdentifier else { return }
                
                if (productIdentifier == "com.bigsmashsoftware.vistaweather.removeads") {
                    defaults.set(true, forKey: "RemoveAdsPurchased")
                }
                
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                break
            case .failed:
                print("Purchase Failed...")
                
                if let error = currentTransaction.error {
                    print(error.localizedDescription)
                }
                
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)

                break
            default:
                print("No conditions met...")
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)

                break
            }
        }
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("Error restoring completed transactions - \(error.localizedDescription)")
        
        let alertPurchasesRestoreFailureNotification = Notification.Name(rawValue:"alertPurchasesRestoreFailed")
        NotificationCenter.default.post(name: alertPurchasesRestoreFailureNotification, object: nil)
    }
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        //print("You have finished restoring completed transactions.")
        
        let alertPurchasesRestoredNotification = Notification.Name(rawValue:"alertPurchasesRestored")
        NotificationCenter.default.post(name: alertPurchasesRestoredNotification, object: nil)
    }
}
