//
//  AllGroupsViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/24/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit

class AllGroupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var allGroups = [Group]()
    var filteredArray = [Group]()
    var searching = false
    var selectedGroup:String = ""
    var selectedGroupDescr:String = ""
    var selecterGroupCreator:String = ""
    
    @IBOutlet weak var GroupsTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.GroupsTableView.rowHeight = UITableView.automaticDimension
        self.GroupsTableView.estimatedRowHeight = 600
        GroupsTableView.tableFooterView = UIView()
    }
    
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
        if (searching){
            selectedGroup = filteredArray[indexPath.row].name
            selectedGroupDescr = filteredArray[indexPath.row].description
            selecterGroupCreator = filteredArray[indexPath.row].creator
            
            let currentCell = GroupsTableView.cellForRow(at: indexPath) as! GroupTableViewCell
            self.performSegue(withIdentifier: "ViewGroupSegue", sender: self)
        }
        else {
            selectedGroup = allGroups[indexPath.row].name
            selectedGroupDescr = allGroups[indexPath.row].description
            selecterGroupCreator = allGroups[indexPath.row].creator
            let currentCell = GroupsTableView.cellForRow(at: indexPath) as! GroupTableViewCell
            self.performSegue(withIdentifier: "ViewGroupSegue", sender: self)
            
            
        }
        
        
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
            
        }
    }
    

}
