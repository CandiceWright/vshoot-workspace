//
//  IAPService.swift
//  VShootApplication
//
//  Created by Candice Wright on 6/22/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import Foundation
import StoreKit

class IAPService: NSObject {
    private override init() {}
    
    static let shared = IAPService()
    var products = [SKProduct]()
    var paymentQueue = SKPaymentQueue.default()
    var purchaseController = PurchaseVshootsViewController()
    
    func getProducts(){
        print("I am getting products")
        let products: Set = [IAPProduct.vshootfunctionality.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchaseProduct(product: IAPProduct){
        guard let productToPurchase = products.filter({$0.productIdentifier == product.rawValue}).first else {return}
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func restore(){
        print("restoring transactions")
        paymentQueue.restoreCompletedTransactions()
    }
    
    func addPurchase(prodID: String){
        SocketIOManager.sharedInstance.purchases[prodID] =  true
    }
}

extension IAPService: SKProductsRequestDelegate{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        print("got product response")
        print(response)
        for product in response.products{
            print(product.localizedTitle)
        }
    }
    
}

extension IAPService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            switch transaction.transactionState {
                case .purchasing: break
                case .restored:
                    queue.finishTransaction(transaction)
                    addPurchase(prodID: transaction.payment.productIdentifier)
                case .purchased:
                    queue.finishTransaction(transaction)
                    self.purchaseController.donePurchasing()
                    addPurchase(prodID: transaction.payment.productIdentifier)
                case .failed:
                    queue.finishTransaction(transaction)
                    self.purchaseController.enablePurchaseBtn()
                default: queue.finishTransaction(transaction)
                
            }
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
        case .deferred: return "deferred"
        case .failed: return "failed"
        case .purchased: return "purchased"
        case .purchasing: return "purchasing"
        case .restored: return "restored"
        }
    }
}
