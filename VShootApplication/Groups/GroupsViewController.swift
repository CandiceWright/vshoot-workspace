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

class GroupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
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
        if (mygroups.count == 0){
            groupsTableView.isHidden = true
        }
        else {
            self.groupsTableView.rowHeight = UITableView.automaticDimension
            self.groupsTableView.estimatedRowHeight = 600
            groupsTableView.tableFooterView = UIView()
        }
        
    }
    
    @IBAction func showGroups(_ sender: Any) {
        allgroups.removeAll()
        //first make a get request to get all users
        let geturl = SocketIOManager.sharedInstance.serverUrl + "/groups/all"
        let url = URL(string: geturl)
        Alamofire.request(url!)
            .validate(statusCode: 200..<201)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let data):
                    print(data)
                    if let groupDict = data as? [Dictionary<String,String>]{
                        //print(groupDict[0]["gName"])
                        for i in 0..<groupDict.count {
                            
                            let newgroup = Group.init(name: groupDict[i]["gName"]!, creator: groupDict[i]["creator"]!, description: groupDict[i]["gDescription"]!)
                            self.allgroups.append(newgroup)
                        }
                        self.performSegue(withIdentifier: "ShowAllGroupsSegue", sender: self)
                    
                    }
                    else {
                        print("cannot convert to dict")
                        let alertController = UIAlertController(title: "Sorry!", message:
                            "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    
                    
                case .failure(let error):
                    print("failure")
                    print(error)
                    let alertController = UIAlertController(title: "Sorry!", message:
                        "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return self.mygroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        let cell = groupsTableView.dequeueReusableCell(withIdentifier: "MyGroupsCell") as! MyGroupsTableViewCell
    
            cell.groupName.text = mygroups[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        groupsTableView.deselectRow(at: indexPath, animated: true)
        
        selectedGroup = mygroups[indexPath.row].name
        selectedGroupDescr = mygroups[indexPath.row].description
        selecterGroupCreator = mygroups[indexPath.row].creator
        
        let newGroupString = selectedGroup.replacingOccurrences(of: " ", with: "%20")
        let currentCell = groupsTableView.cellForRow(at: indexPath) as! MyGroupsTableViewCell
        //check to see if they are apart of the group already
        let geturl = SocketIOManager.sharedInstance.serverUrl + "/groups/members/" + SocketIOManager.sharedInstance.currUserObj.username + "/" + newGroupString
        let url = URL(string: geturl)
        Alamofire.request(url!)
            .validate(statusCode: 200..<201)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let data):
                    print(data)
                    if let memberDict = data as? [Dictionary<String,String>]{
                        if (memberDict.count == 0){
                            //user is not in group
                            self.inGroup = false
                        }
                        else {
                            self.inGroup = true
                        }
                        //get group members
                        let geturl = SocketIOManager.sharedInstance.serverUrl + "/groups/members/" + newGroupString
                        let url = URL(string: geturl)
                        Alamofire.request(url!)
                            .validate(statusCode: 200..<201)
                            .responseJSON{ (response) in
                                switch response.result {
                                case .success(let data):
                                    print(data)
                                    if let memberDict = data as? [Dictionary<String,String>]{
                                        for i in 0..<memberDict.count {
                                            let newUser = User.init(username: memberDict[i]["name"]!, imageUrl: memberDict[i]["image"]!)
                                            self.members.append(newUser)
                                        }
                                        self.performSegue(withIdentifier: "ShowGroupDetailsFromMyGroups", sender: self)
                                    }
                                    else {
                                        print("cant convert dictionary")
                                        let alertController = UIAlertController(title: "Sorry!", message:
                                            "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                                        
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                    
                                    
                                    
                                case .failure(let error):
                                    print("failure")
                                    print(error)
                                    let alertController = UIAlertController(title: "Sorry!", message:
                                        "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                                    
                                    self.present(alertController, animated: true, completion: nil)
                                }
                        }
                    }
                    else {
                        print("cant convert dictionary")
                        let alertController = UIAlertController(title: "Sorry!", message:
                            "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    
                    
                case .failure(let error):
                    print("failure")
                    print(error)
                    let alertController = UIAlertController(title: "Sorry!", message:
                        "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShowAllGroupsSegue"){
            let allGroupsView = segue.destination as? AllGroupsViewController
            allGroupsView?.allGroups = self.allgroups
            
            
        }
        else if(segue.identifier == "ShowGroupDetailsFromMyGroups"){
            let detailsView = segue.destination as? GroupDetailsViewController
            detailsView?.creator = self.selecterGroupCreator
            detailsView?.name = self.selectedGroup
            detailsView?.descr = self.selectedGroupDescr
            detailsView?.inGroup = self.inGroup
            detailsView?.fromAllGroups = false
            detailsView?.members = self.members
        }
    }
    

}
