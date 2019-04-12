//
//  InformationResetViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 2/19/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit

class InformationResetViewController: UIViewController {

    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var passwordBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.usernameBtn.layer.cornerRadius = CGFloat(Float(5.0))
        self.passwordBtn.layer.cornerRadius = CGFloat(Float(5.0))
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
