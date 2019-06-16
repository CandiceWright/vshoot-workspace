//
//  GroupsViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/20/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Alamofire

class GroupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    var mygroups = SocketIOManager.sharedInstance.currUserObj.groups
    var selectedGroup:String = ""
    var selectedGroupDescr:String = ""
    var selecterGroupCreator:String = ""
    var inGroup:Bool = false
    var allgroups = [Group]()
    var members = [User]()
    
    @IBOutlet weak var groupsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataReloadManager.shared.firstVC = self
        if (SocketIOManager.sharedInstance.currUserObj.groups.count == 0){
            print("no groups")
            groupsTableView.isHidden = true
        }
        else {
            self.groupsTableView.rowHeight = UITableView.automaticDimension
            self.groupsTableView.estimatedRowHeight = 600
            groupsTableView.tableFooterView = UIView()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("in view controller the number of groups in array")
        print(SocketIOManager.sharedInstance.currUserObj.groups.count)
        groupsTableView.reloadData()
    }
    
    @IBAction func showGroups(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowAllGroupsSegue", sender: self)

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return SocketIOManager.sharedInstance.currUserObj.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        let cell = groupsTableView.dequeueReusableCell(withIdentifier: "MyGroupsCell") as! MyGroupsTableViewCell
    
            cell.groupName.text = SocketIOManager.sharedInstance.currUserObj.groups[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        groupsTableView.deselectRow(at: indexPath, animated: true)
        print("this is the current idex I am about to print: ")
        print(indexPath.row)
        print("this is the current size of the groups array")
        print(SocketIOManager.sharedInstance.currUserObj.groups.count)
        SocketIOManager.sharedInstance.currUserObj.groups[indexPath.row].printGroup()
        //print("printing selected group info")
        //print(SocketIOManager.sharedInstance.currUserObj.groups[indexPath.row])
        selectedGroup = SocketIOManager.sharedInstance.currUserObj.groups[indexPath.row].name
        selectedGroupDescr = SocketIOManager.sharedInstance.currUserObj.groups[indexPath.row].description
        print("printing selected group description")
        print(SocketIOManager.sharedInstance.currUserObj.groups[indexPath.row].description)
        selecterGroupCreator = SocketIOManager.sharedInstance.currUserObj.groups[indexPath.row].creator
        
        self.performSegue(withIdentifier: "ShowGroupDetailsFromMyGroups", sender: self)
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShowAllGroupsSegue"){
            //let allGroupsView = segue.destination as? AllGroupsViewController
            //allGroupsView?.allGroups = self.allgroups
            
            
        }
        else if(segue.identifier == "ShowGroupDetailsFromMyGroups"){
            let detailsView = segue.destination as? GroupDetailsViewController
            detailsView?.creator = self.selecterGroupCreator
            detailsView?.name = self.selectedGroup
            detailsView?.descr = self.selectedGroupDescr
            print("printing description before segue to details")
            print(self.selectedGroupDescr)
            detailsView?.inGroup = true
            detailsView?.fromAllGroups = false
            //detailsView?.members = self.members
        }
    }
    

}
