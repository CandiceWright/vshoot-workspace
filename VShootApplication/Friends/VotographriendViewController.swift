//
//  VotographriendViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 12/9/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class VotographriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FriendCellDelegate {
    
    //need a list of friends from database
    var friends = [User]()
    var Users = [User]()
    var filteredArray = [User]()
    var searching = false
    var selectedUsername:String = ""
    var selectedImg:UIImage = UIImage()
    var btnOpTxt:String = ""
    
    @IBOutlet weak var friendTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.hideKeyboard()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //populate friends list
        self.friendTableView.rowHeight = UITableView.automaticDimension
        self.friendTableView.estimatedRowHeight = 600
        friendTableView.tableFooterView = UIView()
        self.friends.removeAll()
        let currUser = SocketIOManager.sharedInstance.currUser
        let geturl = SocketIOManager.sharedInstance.serverUrl + "/friends/" + currUser
        let url = URL(string: geturl)
        Alamofire.request(url!)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let data):
                    print(data)
                    if let friendDict = data as? [Dictionary<String,String>]{
                        print("successfully converted friend response")
                        //change result to an array of friends like you did with the array of users in addFriend
                        for i in 0..<friendDict.count {
                            let newUser = User.init(username: friendDict[i]["username"]!, image: friendDict[i]["pic"]!, isFriends: true)
                            self.friends.append(newUser)
                        }
                        
                        self.friendTableView.reloadData()
                        
                        
                    }
                    else {
                        print("couldnt convert friends")
                    }
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    @IBAction func addFriend(_ sender: Any) {
        
        Users.removeAll()
        //first make a get request to get all users
        let geturl = SocketIOManager.sharedInstance.serverUrl + "/users/"
        let url = URL(string: geturl)
        Alamofire.request(url!)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let data):
                    print(data)
                    if let usernameDict = data as? [Dictionary<String,String>]{
                        print(usernameDict[0]["username"])
                        for i in 0..<usernameDict.count {
                            var areFriends:Bool = false;
                            for j in 0..<self.friends.count{
                                if (self.friends[j].username == usernameDict[i]["username"]){ //they are friends
                                    areFriends = true;
                                }
                            }
                            let newUser = User.init(username: usernameDict[i]["username"]!, image: usernameDict[i]["profilePic"]!, isFriends: areFriends)
                            self.Users.append(newUser)
                        }
                        print(self.Users[0].username)
                        self.performSegue(withIdentifier: "addFriendSegue", sender: self)
                    }
                    else {
                        print("cannot convert to dict")
                    }



                case .failure(let error):
                    print("failure")
                    print(error)
                }
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searching){
            return filteredArray.count
        }
        else {
          return friends.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = friendTableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendTableViewCell
        cell.delegate = self
        cell.startVSButton.isHidden = true
        if (searching){
            cell.friendUsername.text = filteredArray[indexPath.row].username
            let picUrl = filteredArray[indexPath.row].image
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
            cell.friendUsername.text = friends[indexPath.row].username
            let picUrl = friends[indexPath.row].image
            if (picUrl == "none"){
                let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
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
            selectedImg = currentCell.friendPic.image!
            if (filteredArray[indexPath.row].isFriends == true){
                //show remove button
                btnOpTxt = "Remove"
            }
            else {
                btnOpTxt = "Add"
            }
        }
        else {
            selectedUsername = friends[indexPath.row].username
            let currentCell = friendTableView.cellForRow(at: indexPath) as! FriendTableViewCell
            selectedImg = currentCell.friendPic.image!
            if (friends[indexPath.row].isFriends == true){
                //show remove button
                btnOpTxt = "Remove"
            }
            else {
                btnOpTxt = "Add"
            }
        }
        
        //also assign image
        self.performSegue(withIdentifier: "manageFriendsFromListSegue", sender: self)
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
        filteredArray = self.friends.filter({$0.username.localizedCaseInsensitiveContains(searchText)})
        if (searchText.count != 0){
            searching = true
        }
        else {
            searching = false
        }
        friendTableView.reloadData()
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
            addFriendVC?.users = self.Users
        }
        else if(segue.identifier == "manageFriendsFromListSegue"){
            let manageFriendshipVC = segue.destination as? ManageFriendshipsViewController
            manageFriendshipVC?.currUser = self.selectedUsername
            manageFriendshipVC?.opBtnTxt = self.btnOpTxt
            manageFriendshipVC?.userImg = selectedImg
            //also set image
        }
        
    }
 

}
