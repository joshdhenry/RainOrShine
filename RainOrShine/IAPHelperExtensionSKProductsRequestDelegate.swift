//
//  IAPHelperExtensionSKProductsRequestDelegate.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/24/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import StoreKit

extension IAPHelper: SKProductsRequestDelegate {
    
    // MARK: - Methods
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
}
