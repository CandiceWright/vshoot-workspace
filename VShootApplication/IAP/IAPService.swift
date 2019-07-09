//
//  IAPService.swift
//  VShootApplication
//
//  Created by Candice Wright on 6/22/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import Foundation
import StoreKit
import Alamofire

class IAPService: NSObject {
    private override init() {}
    var dataString = ""
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
        //record purchase in db
        var posturl = SocketIOManager.sharedInstance.serverUrl + "/vshoots/purchases"
        
        let info: [String:Any] = ["username": SocketIOManager.sharedInstance.currUserObj.username as Any]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: info, options: [])
            dataString = String(data: data, encoding: .utf8)!
        } catch {
            print("error")
        }
        
        let url = URL(string: posturl);
        
        Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
            .validate(statusCode: 200..<201)
            .responseString{ (response) in
                print(response)
                switch response.result {
                case .success(let data):
                    print("successfully recorded purchase")
                    
                case .failure(let error):
                    print("failure")
                    print(error)
                    
                }
        }
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
