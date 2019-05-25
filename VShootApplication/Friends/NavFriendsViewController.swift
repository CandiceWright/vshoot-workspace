//
//  NavFriendsViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/20/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class NavFriendsViewController: UINavigationController, IndicatorInfoProvider {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Friends")
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
