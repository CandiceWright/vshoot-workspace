//
//  WalkthroughContentViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 2/15/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit

class WalkthroughContentViewController: UIViewController {

    @IBOutlet weak var content: UIImageView!
    
    var index = 0
    var imageFile = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        content.image = UIImage(named: imageFile)
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
