//
//  IAPHelper.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/24/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import StoreKit

class IAPHelper: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var productID: String = String()
    let defaults = UserDefaults.standard

    
    func addPaymentObserver() {
        //Add the observer
        SKPaymentQueue.default().add(self)
    }
    
    //Buy a product by adding a payment to the SKPaymentQueue
    func buyProduct(product: SKProduct){
        print("Sending the Payment Request to Apple")
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    
    //If the product ID requested matches a product, purchase it by running buyProduct()
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (!response.products.isEmpty) {
            let validProducts = response.products
            
            for thisProduct in validProducts {
                if (thisProduct.productIdentifier == productID) {
                    print(thisProduct.localizedTitle)
                    print(thisProduct.localizedDescription)
                    print(thisProduct.price)
                    
                    buyProduct(product: thisProduct)
                }
                else {
                    print(thisProduct.productIdentifier)
                }
            }
        }
        else {
            print("Error - Product request returned no products.")
        }
    }
    
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error Fetching product information")
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple")
        
        for transaction: AnyObject in transactions {
            if let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    defaults.set(true, forKey: "purchased")
                    break
                case .failed:
                    print("Purchased Failed")
                    print(trans.error?.localizedDescription)
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    print("Already Purchased")
                    SKPaymentQueue.default().restoreCompletedTransactions()
                default:
                    print("No conditions met...")
                    break
                }
            }
        }
    }
    
    
    func startProductRequest() {
        if (SKPaymentQueue.canMakePayments()) {
            self.productID = "com.bigsmashsoftware.vistaweather.removeads"
            let productIDSet: Set<String> = [productID]
            
            let productsRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productIDSet)
            productsRequest.delegate = self
            productsRequest.start()
            
            print("Fetching Products")
        }
        else{
            print("Error - This user can't make purchases.");
        }
    }
}
