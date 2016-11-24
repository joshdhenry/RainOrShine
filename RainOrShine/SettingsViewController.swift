//
//  SettingsViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/5/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class SettingsViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // MARK: - Properties
    private lazy var selectedSettingsCategory: String = String()
    
    let defaults = UserDefaults.standard
    
    var productID: String = String()
    
    
    override func viewDidLoad() {
        //productID = "com.bigsmashsoftware.vistaweather.removeads"
        super.viewDidLoad()
        
        //Add the observer (DOES THIS GO IN APPDELEFATE?)
        SKPaymentQueue.default().add(self)
        
        if (defaults.bool(forKey: "purchased")){
            print("ADS REMOVED HAS BEEN PURCHASED...")
        }
    }
    
    
    // MARK: - Methods
    //If a cell is tapped, generate the variable to send to SettingsDetailTableViewController and segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            selectedSettingsCategory = "Temperature Unit"
            performSegue(withIdentifier: "segueSettingsDetail", sender: self)
        case (0, 1):
            selectedSettingsCategory = "Update Weather Every"
            performSegue(withIdentifier: "segueSettingsDetail", sender: self)
        case (1, 0):
            selectedSettingsCategory = "Use Default Photos"
            performSegue(withIdentifier: "segueSettingsDetail", sender: self)
        case (1, 1):
            selectedSettingsCategory = "Change Photo Every"
            performSegue(withIdentifier: "segueSettingsDetail", sender: self)
        case (3, 0):
            if (SKPaymentQueue.canMakePayments()) {
                productID = "com.bigsmashsoftware.vistaweather.removeads"
                let productIDSet: Set<String> = [productID]
                
                let productsRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productIDSet)
                productsRequest.delegate = self
                productsRequest.start()
                
                print("Fetching Products")
            }
            else{
                print("Error - This user can't make purchases.");
            }
        default:
            return
        }
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
    
    
    //If about to segue, send over the selected settings category
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueSettingsDetail") {
            guard let segueViewController = segue.destination as? SettingsDetailTableViewController else {return}
            
            segueViewController.currentSettingsCategory = selectedSettingsCategory
        }
    }
}
