//
//  NavVotographerProfileViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 3/1/20.
//  Copyright © 2020 Candice Wright. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class NavVotographerProfileViewController: UINavigationController, IndicatorInfoProvider {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Votographer")
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
