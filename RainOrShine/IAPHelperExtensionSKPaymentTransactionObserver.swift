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
    //Handle transactions and the response from Apple's servers
    internal func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple")
        
        for transaction: AnyObject in transactions {
            guard let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction else {return}
            
            print("Transaction state is \(trans.transactionState.rawValue)")
            
            switch trans.transactionState {
            case .purchasing:
                print("Purchasing item...")
            case .purchased:
                print("Product Purchased")
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                defaults.set(true, forKey: "RemoveAdsPurchased")
                break
            case .failed:
                print("Purchased Failed")
                if let error = trans.error {
                    print(error.localizedDescription)
                }
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                break
            case .restored:
                print("Already Purchased")
                SKPaymentQueue.default().restoreCompletedTransactions()
                
                //Not sure if this is needed?
            //SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
            default:
                print("No conditions met...")
                break
            }
        }
    }
}
