//
//  AddFriendsViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 12/10/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class AddFriendsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate,UITableViewDataSource,AddFriendCellDelegate {
    //var friends = SocketIOManager.sharedInstance.currUserObj.friends
    var users = [User]()
    var filteredArray = [User]()
    var selectedUsername:String = ""
    var selectedImg:UIImage = UIImage()
    var btnOpTxt:String = ""
    var searching = false
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        print(users.count)
        usersTable.tableFooterView = UIView()
        usersTable.rowHeight = UITableView.automaticDimension
        usersTable.estimatedRowHeight = 600
        cancelBtn.layer.borderColor =  UIColor.black.cgColor
        cancelBtn.layer.borderWidth = 0.2
        usersTable.isHidden = true
        
        users.removeAll()
        
        //first get all users
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
                        self.usersTable.isHidden = false
                        var idx:Int = 0
                        while(idx != usernameDict.count){
                            print("idx: ")
                            print(idx)
                            self.populateUser(data: usernameDict[idx], completion: {
                                print("block complete")
                                //idx += 1
                            })
                            idx += 1
                        }
//                        for i in 0..<usernameDict.count {
//                            print("username I am currently getting image for")
//                            print(usernameDict[i]["username"]!)
//                            let newUser = User.init(username: usernameDict[i]["username"]!, imageUrl: usernameDict[i]["profilePic"]!)
//                            if (usernameDict[i]["profilePic"]! == "none"){
//                                let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
//                                newUser.image = noProfileImage
//                                self.users.append(newUser)
//                                self.usersTable.reloadData()
//
//                            }
//                            else {
//                                ImageService.getImage(withURL: usernameDict[i]["profilePic"]!, completion: {image in
//                                    print("got image")
//                                    newUser.image = image
//                                    self.users.append(newUser)
//                                    self.usersTable.reloadData()
//                                })
//                            }
//
//                        }
                        //self.usersTable.isHidden = false
                        print(self.users[0].username)
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
    
    func populateUser(data: Dictionary<String, String>, completion: @escaping () -> ()){
        //for i in 0..<usernameDict.count {
            print("username I am currently getting image for")
            print(data["username"])
            let newUser = User.init(username: data["username"]!, imageUrl: data["profilePic"]!)
            if (data["profilePic"]! == "none"){
                let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
                newUser.image = noProfileImage
                self.users.append(newUser)
                self.usersTable.reloadData()
                completion()
                
            }
            else {
                ImageService.getImage(withURL: data["profilePic"]!, completion: {image in
                    print("got image")
                    newUser.image = image
                    self.users.append(newUser)
                    self.usersTable.reloadData()
                    completion()
                })
            }
            
        //}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searching){
            return filteredArray.count
        }
        else {
            return users.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTable.dequeueReusableCell(withIdentifier: "AddFriendCell") as! AddFriendTableViewCell
        cell.delegate = self
        if (searching){
            cell.friendUsername.text = filteredArray[indexPath.row].username
            //let picUrl = filteredArray[indexPath.row].imageUrl
            //if (picUrl == "none"){
                let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
                //cell.friendPic.image = noProfileImage
            cell.friendPic.image = filteredArray[indexPath.row].image
                cell.friendPic.layer.cornerRadius = cell.friendPic.frame.height/2
                cell.friendPic.clipsToBounds = true
                cell.friendPic.layer.masksToBounds = true
                
//            }
//            else {
//                cell.setPic(url: picUrl)
//            }
        }
        else {
            cell.friendUsername.text = users[indexPath.row].username
            let picUrl = users[indexPath.row].imageUrl
           // if (picUrl == "none"){
                let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
                //cell.friendPic.image = noProfileImage
            cell.friendPic.image = users[indexPath.row].image
                cell.friendPic.layer.cornerRadius = cell.friendPic.frame.height/2
                cell.friendPic.clipsToBounds = true
                cell.friendPic.layer.masksToBounds = true
            //}
//            else {
//                cell.setPic(url: picUrl)
//
//            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        usersTable.deselectRow(at: indexPath, animated: true)
        if (searching){
            selectedUsername = filteredArray[indexPath.row].username
            let currentCell = usersTable.cellForRow(at: indexPath) as! AddFriendTableViewCell
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
                self.performSegue(withIdentifier: "addFriendPopup", sender: self)
            }
           
        }
        else {
            selectedUsername = users[indexPath.row].username
            let currentCell = usersTable.cellForRow(at: indexPath) as! AddFriendTableViewCell
            if (currentCell.friendPic.image != nil){
                selectedImg = currentCell.friendPic.image!
                print("printing friend count in add friend controlle: ")
                print(SocketIOManager.sharedInstance.currUserObj.friends.count)
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
                self.performSegue(withIdentifier: "addFriendPopup", sender: self)
            }
        }
        
        
    }
    
    func didTapAddFriend(username: String) {
        //send request to server to add new friend
    }
    

    @IBOutlet weak var searchUsers: UISearchBar!
    
    
    @IBAction func closeAddview(_ sender: Any) {
        //dismiss(animated: true, completion: nil)
        //self.performSegue(withIdentifier: "backToFriendsList", sender: self)
        print(self.navigationController?.viewControllers.count)
        for controller in self.navigationController!.viewControllers as Array {
            print(controller.title!)
            if controller.title == "friendList" {
            //if controller.isKind(of: VotographerViewController) {
           print("found view controller to pop")
            self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //add filtering code here
        //localizedCaseInsensitiveContains
//        filteredArray = self.users.filter({$0.username.prefix(searchText.count) == (searchText)})
        print(searchText.count)
        filteredArray = self.users.filter({$0.username.localizedCaseInsensitiveContains(searchText)})
        if (searchText.count != 0){
            searching = true
        }
        else {
            searching = false
        }
        usersTable.reloadData()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToFriendsList" {
            hidesBottomBarWhenPushed = true
            DispatchQueue.main.async { self.hidesBottomBarWhenPushed = false }
        }
        else {
            let manageFriendshipVC = segue.destination as? ManageFriendshipsViewController
            manageFriendshipVC?.currUser = self.selectedUsername
            manageFriendshipVC?.opBtnTxt = self.btnOpTxt
            manageFriendshipVC?.userImg = selectedImg
            manageFriendshipVC?.Users = self.users
            //also set image
        }
        
    }
 

}

