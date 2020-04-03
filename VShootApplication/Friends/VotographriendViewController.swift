//
//  VotographriendViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 12/9/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire
import XLPagerTabStrip

class VotographriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FriendCellDelegate, ModalTransitionListener  {
    
    //need a list of friends from database
    //var friends = SocketIOManager.sharedInstance.currUserObj.friends
    var Users = [User]()
    var selectedUser = User(username: "", imageUrl: "")
    var filteredArray = [User]()
    var searching = false
    var selectedUsername:String = ""
    var selectedImg:UIImage = UIImage()
    var btnOpTxt:String = ""
    
    @IBOutlet weak var friendTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ModalTransitionMediator.instance.setListener(listener: self)
        
        self.hideKeyboard()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //populate friends list
        self.friendTableView.rowHeight = UITableView.automaticDimension
        self.friendTableView.estimatedRowHeight = 600
        friendTableView.tableFooterView = UIView()
        //self.friends.removeAll()
        //friends = SocketIOManager.sharedInstance.currUserObj.friends
        //print(friends.count)
        friendTableView.reloadData()
        self.loadGroups()
        
        
    }
    
    func popoverDismissed() {
        self.navigationController?.dismiss(animated: true, completion: nil)
        friendTableView.reloadData()
    }
    @IBAction func close(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addFriend(_ sender: Any) {
    
        //if (self.Users.count != 0){
            self.performSegue(withIdentifier: "addFriendSegue", sender: self)
        //}
        //else {
            //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                //self.performSegue(withIdentifier: "addFriendSegue", sender: self)
            //})
        //}

        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searching){
            return filteredArray.count
        }
        else {
            print(SocketIOManager.sharedInstance.currUserObj.friends.count)
          return SocketIOManager.sharedInstance.currUserObj.friends.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        let cell = friendTableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendTableViewCell
        cell.delegate = self
        cell.startVSButton.isHidden = true
        if (searching){
            cell.friendUsername.text = filteredArray[indexPath.row].username
            let picUrl = filteredArray[indexPath.row].imageUrl
            if (picUrl == "none"){
                let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
                cell.friendPic.image = noProfileImage
                cell.friendPic.layer.cornerRadius = cell.friendPic.frame.height/2
                cell.friendPic.clipsToBounds = true
            }
            else {
                cell.setPic(url: picUrl)
            }
        }
        else {
            cell.friendUsername.text = SocketIOManager.sharedInstance.currUserObj.friends[indexPath.row].username
            print("trying to add row")
            let picUrl = SocketIOManager.sharedInstance.currUserObj.friends[indexPath.row].imageUrl
            if (picUrl == "none"){
                let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
                print("size: ")
                print(cell.friendPic.frame.height)
                print(cell.friendPic.frame.width)
                cell.friendPic.image = noProfileImage
                cell.friendPic.layer.cornerRadius = cell.friendPic.frame.height/2
                cell.friendPic.clipsToBounds = true
                cell.friendPic.layer.masksToBounds = true
            }
            else {
                cell.setPic(url: picUrl)
            }
        }
       
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        friendTableView.deselectRow(at: indexPath, animated: true)
        if (searching){
            selectedUsername = filteredArray[indexPath.row].username
            let currentCell = friendTableView.cellForRow(at: indexPath) as! FriendTableViewCell
            if (currentCell.friendPic.image != nil){
                selectedImg = currentCell.friendPic.image!
                btnOpTxt = "Remove"
                for i in 0..<SocketIOManager.sharedInstance.currUserObj.friends.count {
                    if (SocketIOManager.sharedInstance.currUserObj.friends[i].username == selectedUsername){
                        selectedUser = SocketIOManager.sharedInstance.currUserObj.friends[i]
                    }
                }

                //also assign image
                self.performSegue(withIdentifier: "manageFriendsFromListSegue", sender: self)
            }
            

        }
        else {
            
            selectedUsername = SocketIOManager.sharedInstance.currUserObj.friends[indexPath.row].username
            let currentCell = friendTableView.cellForRow(at: indexPath) as! FriendTableViewCell
            if(currentCell.friendPic.image != nil){
                selectedImg = currentCell.friendPic.image!
                btnOpTxt = "Remove"
//                var areFriends = false
                for i in 0..<SocketIOManager.sharedInstance.currUserObj.friends.count {
                    if (SocketIOManager.sharedInstance.currUserObj.friends[i].username == selectedUsername){
                        selectedUser = SocketIOManager.sharedInstance.currUserObj.friends[i]
                    }
                }

                self.performSegue(withIdentifier: "manageFriendsFromListSegue", sender: self)
            }
            
        }
        
        
    }
    
    
    func didTapStartVS(friendName: String) {
        //segue to new vs controller and Autoselect votographer as the one they selected
        //also send list of friends maybe. For now only allow them to shoot with the person they selcted. If they want options, they can start vshoot from vs tab
    }
    

    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //add filtering code here
        //localizedCaseInsensitiveContains
        //        filteredArray = self.users.filter({$0.username.prefix(searchText.count) == (searchText)})
        print(searchText.count)
        filteredArray = SocketIOManager.sharedInstance.currUserObj.friends.filter({$0.username.localizedCaseInsensitiveContains(searchText)})
        if (searchText.count != 0){
            searching = true
        }
        else {
            searching = false
        }
        friendTableView.reloadData()
    }
    
    func loadGroups(){
        let geturl2 = SocketIOManager.sharedInstance.serverUrl + "/groups/" + SocketIOManager.sharedInstance.currUserObj.username
            let url = URL(string: geturl2)
            Alamofire.request(url!)
                .responseJSON{ (response) in
                    switch response.result {
                    case .success(let data):
                        print(data)
                        if let groupDict = data as? [Dictionary<String,String>]{
                            print("successfully converted group response")
                            //change result to an array of friends like you did with the array of users in addFriend
                            SocketIOManager.sharedInstance.currUserObj.groups.removeAll()
                            for i in 0..<groupDict.count {
                                let newGroup = Group.init(name: groupDict[i]["name"]!, creator: groupDict[i]["creator"]!, description: groupDict[i]["description"]!)
                                SocketIOManager.sharedInstance.currUserObj.groups.append(newGroup)
                            }
                            print("done adding groups")
    //                        self.getProfilePic(username: username)
                        }
                        else {
                            print("couldnt convert friends at 221")
                        }
                        
                        
                    case .failure(let error):
                        print(error)
                    }
                    
            }
        }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "addFriendSegue"){
            let addFriendVC = segue.destination as? AddFriendsViewController
            print("current size of users array before segue")
            print(Users.count)
            //addFriendVC?.users = self.Users
        }
        else if(segue.identifier == "manageFriendsFromListSegue"){
            let manageFriendshipVC = segue.destination as? ManageFriendshipsViewController
            manageFriendshipVC?.currUser = self.selectedUsername
            manageFriendshipVC?.opBtnTxt = self.btnOpTxt
            manageFriendshipVC?.userImg = selectedImg
            //manageFriendshipVC?.Users = self.Users
            manageFriendshipVC?.selectedUser = self.selectedUser
            manageFriendshipVC?.fromFriendsPage = true
            //also set image
        }
        
    }
 

}
