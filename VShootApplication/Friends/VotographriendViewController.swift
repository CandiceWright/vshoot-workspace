//
//  VotographriendViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 12/9/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class VotographriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FriendCellDelegate, ModalTransitionListener {
    
    //need a list of friends from database
    //var friends = SocketIOManager.sharedInstance.currUserObj.friends
    var Users = [User]()
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
        
        Users.removeAll()
        //first make a get request to get all users
        let geturl = SocketIOManager.sharedInstance.serverUrl + "/users/"
        let url = URL(string: geturl)
        Alamofire.request(url!)
            .validate(statusCode: 200..<201)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let data):
                    print(data)
                    if let usernameDict = data as? [Dictionary<String,String>]{
                        print(usernameDict[0]["username"])
                        for i in 0..<usernameDict.count {
                            
                            let newUser = User.init(username: usernameDict[i]["username"]!, imageUrl: usernameDict[i]["profilePic"]!)
                            self.Users.append(newUser)
                        }
                        print(self.Users[0].username)
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
    
    func popoverDismissed() {
        self.navigationController?.dismiss(animated: true, completion: nil)
        friendTableView.reloadData()
    }
    
    @IBAction func addFriend(_ sender: Any) {
    
        if (self.Users.count != 0){
            self.performSegue(withIdentifier: "addFriendSegue", sender: self)
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.performSegue(withIdentifier: "addFriendSegue", sender: self)
            })
        }

        
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
                var areFriends = false
                for i in 0..<SocketIOManager.sharedInstance.currUserObj.friends.count {
                    if (SocketIOManager.sharedInstance.currUserObj.friends[i].username == selectedUsername){
                        areFriends = true
                    }
                }
                if (areFriends){
                    btnOpTxt = "Remove"
                }
                else {
                    btnOpTxt = "Add"
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
                var areFriends = false
                for i in 0..<SocketIOManager.sharedInstance.currUserObj.friends.count {
                    if (SocketIOManager.sharedInstance.currUserObj.friends[i].username == selectedUsername){
                        areFriends = true
                    }
                }
                if (areFriends){
                    btnOpTxt = "Remove"
                }
                else {
                    btnOpTxt = "Add"
                }
                //also assign image
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
            manageFriendshipVC?.Users = self.Users
            manageFriendshipVC?.fromFriendsPage = true
            //also set image
        }
        
    }
 

}
