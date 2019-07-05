//
//  PurchaseVshootsViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 6/29/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit

class PurchaseVshootsViewController: UIViewController {

    @IBOutlet weak var purchaseBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var pView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.purchaseBtn.layer.cornerRadius = CGFloat(Float(6.0))
        self.pView.layer.cornerRadius = CGFloat(Float(7.0))
        IAPService.shared.purchaseController = self
    }
    
    @IBAction func purchaseVS(_ sender: Any) {
        if(purchaseBtn.currentTitle == "Start VShooting!"){
            dismiss(animated: true, completion: nil)
        }
        else {
            purchaseBtn.isEnabled = false
            IAPService.shared.purchaseProduct(product: .vshootfunctionality)
        }
        
    }
    
    func donePurchasing(){
        purchaseBtn.setTitle("Start VShooting!", for: UIControl.State.normal)
        purchaseBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        purchaseBtn.backgroundColor = UIColor.white
        purchaseBtn.isEnabled = true
        cancelBtn.isHidden = true
    }
    
    func enablePurchaseBtn(){
        purchaseBtn.isEnabled = true
    }
    
    @IBAction func cancelPurchase(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
