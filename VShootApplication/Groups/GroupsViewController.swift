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

class GroupsViewController: UIViewController { //UITableViewDataSource, UITableViewDelegate {
    var mygroups = [Group]()
    var allgroups = [Group]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if (mygroups.count == 0){
//            groupsTableView.isHidden = true
//        }
//        else {
//            self.groupsTableView.rowHeight = UITableView.automaticDimension
//            self.groupsTableView.estimatedRowHeight = 600
//            groupsTableView.tableFooterView = UIView()
//        }
        
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
                        print(groupDict[0]["gName"])
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
    
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        //hello
//        return 0;
//    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        //
//    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShowAllGroupsSegue"){
            let allGroupsView = segue.destination as? AllGroupsViewController
            allGroupsView?.allGroups = self.allgroups
            
            
        }
    }
    

}
