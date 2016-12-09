//
//  IAPHelper.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/24/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import StoreKit

class IAPHelper: NSObject {
    
    // MARK: - Properties
    internal let defaults = UserDefaults.standard

    // MARK: - Initializer
    override init() {
        super.init()
    }
    
    
    func addPaymentQueueObserver() {
        SKPaymentQueue.default().add(self)
    }
    
    
    func removePaymentQueueObserver() {
        SKPaymentQueue.default().remove(self)
    }
    
    
    // MARK: - Methods
    //Buy a product by adding a payment to the SKPaymentQueue
    internal func buyProduct(product: SKProduct){
        print("Sending the Payment Request to Apple")
        
        let payment = SKPayment(product: product)
        print("Product we are paying for is \(product.localizedDescription)")
        SKPaymentQueue.default().add(payment)
    }
    
    
    //Handle errors when fetching products
    internal func request(_ request: SKRequest, didFailWithError error: Error) {
        let purchaseFailureNotification = Notification.Name(rawValue:"PurchaseFailed")
        NotificationCenter.default.post(name: purchaseFailureNotification, object: nil)
    }
    
    
    //Initiate a product purchase
    public func startProductRequest(productID: String) {
        if (SKPaymentQueue.canMakePayments()) {
            let productIDSet: Set<String> = [productID]
            
            let productsRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productIDSet)
            productsRequest.delegate = self
            productsRequest.start()
        }
        else{
            let purchaseFailureNotification = Notification.Name(rawValue:"PurchaseFailed")
            NotificationCenter.default.post(name: purchaseFailureNotification, object: nil)
        }
    }
    
    
    //Restore previously completed transactions
    public func restorePurchases() {
        if (SKPaymentQueue.canMakePayments()) {
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
}
