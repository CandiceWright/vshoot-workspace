//
//  AllGroupsViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/24/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class AllGroupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var allGroups = [Group]()
    var filteredArray = [Group]()
    var searching = false
    var selectedGroup:String = ""
    var selectedGroupDescr:String = ""
    var selecterGroupCreator:String = ""
    var inGroup:Bool = false
    var members = [User]()
    
    @IBOutlet weak var GroupsTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.GroupsTableView.isHidden = true
        //print(allGroups.count)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.hideKeyboard()
        
        allGroups.removeAll()
        //first make a get request to get all users
        let geturl = SocketIOManager.sharedInstance.serverUrl + "/groups/all"
        let url = URL(string: geturl)
        Alamofire.request(url!)
            .validate(statusCode: 200..<201)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let data):
                    print(data)
                    self.GroupsTableView.isHidden = false
                    if let groupDict = data as? [Dictionary<String,String>]{
                        //print(groupDict[0]["gName"])
                        print(groupDict)
                        for i in 0..<groupDict.count {
                            
                            let newgroup = Group.init(name: groupDict[i]["name"]!, creator: groupDict[i]["creator"]!, description: groupDict[i]["description"]!)
                            self.allGroups.append(newgroup)
                            self.GroupsTableView.reloadData()
                        }
//                        self.performSegue(withIdentifier: "ShowAllGroupsSegue", sender: self)
                        
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.GroupsTableView.rowHeight = UITableView.automaticDimension
        self.GroupsTableView.estimatedRowHeight = 600
        GroupsTableView.tableFooterView = UIView()
        
    }
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0 {
//                //keyboardSize.height
//                self.view.frame.origin.y -= 50
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searching){
            return filteredArray.count
        }
        else {
            
            return self.allGroups.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        let cell = GroupsTableView.dequeueReusableCell(withIdentifier: "AddGroupCell") as! GroupTableViewCell
        
        if (searching){
            cell.gName.text = filteredArray[indexPath.row].name
            cell.gDescr.text = filteredArray[indexPath.row].description
            
        }
        else {
            cell.gName.text = allGroups[indexPath.row].name
            cell.gDescr.text = allGroups[indexPath.row].description
            
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        GroupsTableView.deselectRow(at: indexPath, animated: true)
        print("row selected")
        if (searching){
            selectedGroup = filteredArray[indexPath.row].name
            selectedGroupDescr = filteredArray[indexPath.row].description
            selecterGroupCreator = filteredArray[indexPath.row].creator
        }
        else {
            selectedGroup = allGroups[indexPath.row].name
            selectedGroupDescr = allGroups[indexPath.row].description
            selecterGroupCreator = allGroups[indexPath.row].creator
        }
        
        //check if user is in group
        for i in 0..<SocketIOManager.sharedInstance.currUserObj.groups.count {
            print("'" + SocketIOManager.sharedInstance.currUserObj.groups[i].name + "'")
            print("'" + self.selectedGroup + "'")
            if(SocketIOManager.sharedInstance.currUserObj.groups[i].name == self.selectedGroup){
                self.inGroup = true
            }
        }
        
        self.performSegue(withIdentifier: "ViewGroupSegue", sender: self)
        

    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //add filtering code here
        //localizedCaseInsensitiveContains
        //        filteredArray = self.users.filter({$0.username.prefix(searchText.count) == (searchText)})
        print(searchText.count)
        filteredArray = allGroups.filter({$0.name.localizedCaseInsensitiveContains(searchText)})
        if (searchText.count != 0){
            searching = true
        }
        else {
            searching = false
        }
        GroupsTableView.reloadData()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "ViewGroupSegue"){
            let detailsView = segue.destination as? GroupDetailsViewController
            detailsView?.creator = self.selecterGroupCreator
            detailsView?.name = self.selectedGroup
            detailsView?.descr = self.selectedGroupDescr
            detailsView?.inGroup = self.inGroup
            detailsView?.allGroups = self.allGroups
            detailsView?.fromAllGroups = true
            //detailsView?.members = self.members
        }
    }
    

}
