//
//  GroupsViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/20/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class GroupsViewController: UIViewController { //UITableViewDataSource, UITableViewDelegate {
    var groups = [User]()
    
    @IBOutlet weak var groupsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (groups.count == 0){
            groupsTableView.isHidden = true
        }
        else {
            self.groupsTableView.rowHeight = UITableView.automaticDimension
            self.groupsTableView.estimatedRowHeight = 600
            groupsTableView.tableFooterView = UIView()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //hello
        return 0;
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        //
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
