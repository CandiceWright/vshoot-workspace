//
//  GroupDetailsViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/25/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire
import MessengerKit

class GroupDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var name:String = ""
    var descr:String = ""
    var creator:String = ""
    var members = [User]()
    var allGroups = [Group]()
    var inGroup:Bool = false
    var dataString: String = "";
    var fromAllGroups: Bool = true
    var messages:[[MSGMessage]] = [[MSGMessage]]()
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var groupDescr: UITextView!
    
    @IBOutlet weak var groupCreator: UILabel!
    
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var membersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        self.membersTableView.rowHeight = UITableView.automaticDimension
        self.membersTableView.estimatedRowHeight = 600
        membersTableView.tableFooterView = UIView()
        
        self.leaveBtn.layer.cornerRadius = CGFloat(Float(4.0))
        self.chatBtn.layer.cornerRadius = CGFloat(Float(4.0))
        self.joinBtn.layer.cornerRadius = CGFloat(Float(4.0))
        
//        //get chat messages
//        let newGroupString = self.name.replacingOccurrences(of: " ", with: "%20")
//        let geturl = SocketIOManager.sharedInstance.serverUrl + "/groups/chat/" + newGroupString
//        let url = URL(string: geturl)
//        Alamofire.request(url!)
//            .validate(statusCode: 200..<201)
//            .responseJSON{ (response) in
//                switch response.result {
//                case .success(let data):
//                    print(data)
//                    if let messageDict = data as? [Dictionary<String,String>]{
//                        //print(groupDict[0]["gName"])
//                        for i in 0..<messageDict.count {
//                            var isSender = false;
//                            if (messageDict[i]["sender"] == SocketIOManager.sharedInstance.currUserObj.username){
//                                isSender = true
//                            }
//                            ImageService.downloadImage(myUrl: messageDict[i]["userImage"]!){ image in
//                                let chatUser = ChatUser(displayName: messageDict[i]["sender"]!, avatar: image, avatarUrl: nil, isSender: isSender)
//                                let body: MSGMessageBody = .text(messageDict[i]["message"]!)
//                                let message = MSGMessage(id: 1, body: body, user: chatUser, sentAt: Date())
//                                self.messages.append([message])
//                            }
//                        }
//
//                    }
//                    else {
//                        print("cannot convert to dict")
//                        let alertController = UIAlertController(title: "Sorry!", message:
//                            "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
//                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
//
//                        self.present(alertController, animated: true, completion: nil)
//                    }
//
//
//
//                case .failure(let error):
//                    print("failure")
//                    print(error)
//                    let alertController = UIAlertController(title: "Sorry!", message:
//                        "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
//                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
//
//                    self.present(alertController, animated: true, completion: nil)
//                }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = name
        groupDescr.text = descr
        groupCreator.text = creator
        //print(inGroup)
        if (!inGroup){
            chatBtn.isHidden = true
            leaveBtn.isHidden = true
        }
        else {
            joinBtn.isHidden = true
        }
        
    }
    
    @IBAction func joinGroup(_ sender: Any) {
        var posturl = SocketIOManager.sharedInstance.serverUrl + "/groups/members"
        
        let info: [String:Any] = ["username": SocketIOManager.sharedInstance.currUserObj.username as Any, "group": nameLabel.text as Any]
        //"securityQuestion": self.question as Any, "securityAnswer": SQAnswer.text as Any
        do {
            let data = try JSONSerialization.data(withJSONObject: info, options: [])
            dataString = String(data: data, encoding: .utf8)!
        } catch {
            print("error")
        }
        
        let url = URL(string: posturl);
        
        Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
            .validate(statusCode: 200..<201)
            .responseString{ (response) in
                print(response)
                switch response.result {
                case .success(let data):
                    print(data)
                    if (data == "joined group successfully"){
                        let newGroup = Group.init(name: self.name, creator: self.creator, description: self.description)
                        SocketIOManager.sharedInstance.currUserObj.groups.append(newGroup)
                        let alertController = UIAlertController(title: "Great!", message:
                            "You're In!", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                            self.joinBtn.isHidden = true
                            self.leaveBtn.isHidden = false
                            self.chatBtn.isHidden = false
                            self.performSegue(withIdentifier: "BackToMyGroupsFromGroupDets", sender: self)
                        }))
                        
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
    
    @IBAction func leaveGroup(_ sender: Any) {
        //make request to remove friend
        let posturl = SocketIOManager.sharedInstance.serverUrl + "/groups/members/leave"
        //let currU = SocketIOManager.sharedInstance.currUser
        let currU = SocketIOManager.sharedInstance.currUserObj.username
        let removedGroup = nameLabel.text
        var removedUserIndex = -1
        for i in 0..<SocketIOManager.sharedInstance.currUserObj.groups.count{
            if (SocketIOManager.sharedInstance.currUserObj.groups[i].name == removedGroup){
                removedUserIndex = i
            }
        }
        print("current logged in user: " + currU)
        let info: [String:Any] = ["username": currU ,"groupname": removedGroup as Any]
        do {
            let data = try JSONSerialization.data(withJSONObject: info, options: [])
            dataString = String(data: data, encoding: .utf8)!
        } catch {
            print("error")
        }
        
        //let url = URL(string: geturl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        let url = URL(string: posturl);
        
        Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
            .validate(statusCode: 200..<201)
            .responseString{ (response) in
                print(response)
                switch response.result {
                case .success(let data):
                    print(data)
                    print("groups count before removing")
                    print(SocketIOManager.sharedInstance.currUserObj.groups.count)
                    SocketIOManager.sharedInstance.currUserObj.groups.remove(at: removedUserIndex);
                    print("groups count after removing")
                    print(SocketIOManager.sharedInstance.currUserObj.friends.count)
                    
                    self.leaveBtn.isHidden = true
                    self.chatBtn.isHidden = true
                    self.joinBtn.isHidden = false
                    
                    let alertController = UIAlertController(title: "", message:
                        "You have left the group", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                        if(self.fromAllGroups){
                            self.performSegue(withIdentifier: "AllGroupsFromDetailsSeg", sender: self)
                        }
                        else {
                            self.performSegue(withIdentifier: "BackToMyGroupsFromGroupDets", sender: self)
                        }
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                   
                    
                case .failure(let error):
                    print(error)
                    
                    let alertController = UIAlertController(title: "Sorry!", message:
                        "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
        }
    }
    
    @IBAction func chat(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowChatroom", sender: self)
    }
    
    
    @IBAction func backToAllGroups(_ sender: Any) {
        if(fromAllGroups){
           self.performSegue(withIdentifier: "AllGroupsFromDetailsSeg", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "BackToMyGroupsFromGroupDets", sender: self)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = membersTableView.dequeueReusableCell(withIdentifier: "GroupMemberCell") as! GroupMemberTableViewCell
        cell.username.text = self.members[indexPath.row].username
        print("trying to add row")
        let picUrl = self.members[indexPath.row].imageUrl
        if (picUrl == "none"){
            let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
            cell.userImg.image = noProfileImage
            cell.userImg.layer.cornerRadius = cell.userImg.frame.height/2
            cell.userImg.clipsToBounds = true
            cell.userImg.layer.masksToBounds = true
        }
        else {
            cell.setPic(url: picUrl)
        }
        
        return cell
    
    }
    
    
    
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "AllGroupsFromDetailsSeg"){
            let groupsView = segue.destination as? AllGroupsViewController
            groupsView?.allGroups = self.allGroups
        }
        
        else if(segue.identifier == "ShowChatroom"){
            let destViewController = segue.destination as! UINavigationController
            let chatview = destViewController.viewControllers.first as! ChatroomViewController
            chatview.chatname = self.name
            //chatview.messages = self.messages
        }
       
    }
 

}
