//
//  PhotoProcessingViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 1/20/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit

class PhotoProcessingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6), execute: {
            self.dismiss(animated: true, completion: nil)
            
            
        })
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
