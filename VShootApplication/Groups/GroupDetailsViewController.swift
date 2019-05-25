//
//  GroupDetailsViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/25/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit

class GroupDetailsViewController: UIViewController {
    
    var name:String = ""
    var descr:String = ""
    var creator:String = ""
    var members = [String]()
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = name
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
