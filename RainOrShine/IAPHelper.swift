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
    // MARK: - Properties
    private let defaults = UserDefaults.standard

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    
    //Buy a product by adding a payment to the SKPaymentQueue
    private func buyProduct(product: SKProduct){
        print("Sending the Payment Request to Apple")
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    
    //If the product ID requested matches a product, purchase it by running buyProduct()
    internal func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (!response.products.isEmpty) {
            for thisProduct in response.products {
                print(thisProduct.localizedTitle)
                print(thisProduct.localizedDescription)
                print(thisProduct.price)
                
                buyProduct(product: thisProduct)
            }
        }
        else {
            print("Error - Product request returned no products.")
        }
    }
    
    
    //Handle errors when fetching products
    internal func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error Fetching product information")
    }
    
    
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
    
    
    //Initiate a product purchase
    public func startProductRequest(productID: String) {
        if (SKPaymentQueue.canMakePayments()) {
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
