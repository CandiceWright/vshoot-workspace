//
//  ChatroomViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/30/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import Foundation

import UIKit
import MessengerKit
import Alamofire

class ChatroomViewController: MSGMessengerViewController {
    
    var chatname:String = ""
    
//    let steve = ChatUser(displayName: "Steve", avatar: UIImage(named: "profilepic_none"), avatarUrl: nil, isSender: true)
//
//    let tim = ChatUser(displayName: "Tim", avatar: nil, avatarUrl: nil, isSender: false)
    
    
    let currUser = ChatUser(displayName: SocketIOManager.sharedInstance.currUserObj.username, avatar: SocketIOManager.sharedInstance.currUserObj.image!, avatarUrl: nil, isSender: true)
    
    var id = 100
    
    var messages:[[MSGMessage]] = [[MSGMessage]]()
    
    
    // Messages
    
//    lazy var messages: [[MSGMessage]] = {
//        return [
//            [
//                MSGMessage(id: 1, body: .emoji("🐙💦🔫"), user: tim, sentAt: Date()),
//            ],
//            [
//                MSGMessage(id: 2, body: .text("Yeah sure, gimme 5"), user: steve, sentAt: Date()),
//                MSGMessage(id: 3, body: .text("Okay ready when you are"), user: steve, sentAt: Date())
//            ],
//            [
//                MSGMessage(id: 1, body: .emoji("🐙💦🔫"), user: can, sentAt: Date()),
//            ]
//        ]
//    }()
    
    // Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        title = chatname
        
//        let item = self.navigationItem.leftBarButtonItem
//        let button = item!.customView as! UIButton
//        button.setTitle("< Back", for: .normal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "BACK", style: .plain, target: self, action: #selector(goback))
        let greenColor = UIColor(rgb: 0x31D283)
        navigationItem.leftBarButtonItem?.tintColor = greenColor
        
        //add listeners
        SocketIOManager.sharedInstance.socket.on("newMessage") { dataArray, ack in
            print("new message")
            print("dataArray: ")
            print(dataArray)
            let data = dataArray[0] as! Dictionary<String,String>
            print("data: ")
            print(data)
            let groupname = data["group"]
            let msg = data["message"]
            let username = data["username"]
            let date = data["date"]
            let userImgUrl = data["userImg"]
            
            if (groupname == self.chatname){
                if (username != self.currUser.displayName){ //make sure its not a message sent by currUser
                    var profilePic: UIImage = UIImage()
                    if(userImgUrl! == "no profile pic"){
                        profilePic = UIImage(named: "profilepic_none")!
                        let chatUser = ChatUser(displayName: username!, avatar: profilePic, avatarUrl: nil, isSender: false)
                        let body: MSGMessageBody = .text(msg!)
                        let message = MSGMessage(id: 1, body: body, user: chatUser, sentAt: Date())
                        //self.messages.append([message])
                        self.insert(message)
                    }
                    else {
                        ImageService.downloadImage(myUrl: userImgUrl!){ image in
                            profilePic = image!
                            let chatUser = ChatUser(displayName: username!, avatar: profilePic, avatarUrl: nil, isSender: false)
                            let body: MSGMessageBody = .text(msg!)
                            let message = MSGMessage(id: 1, body: body, user: chatUser, sentAt: Date())
                            //self.messages.append([message])
                            self.insert(message)
                        }
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.navigationBar.isHidden = false
        
        //get chat messages
        let newGroupString = self.chatname.replacingOccurrences(of: " ", with: "%20")
        let geturl = SocketIOManager.sharedInstance.serverUrl + "/groups/chat/" + newGroupString
        let url = URL(string: geturl)
        Alamofire.request(url!)
            .validate(statusCode: 200..<201)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let data):
                    print(data)
                    if let messageDict = data as? [Dictionary<String,String>]{
                        var idx:Int = 0
                        while(idx != messageDict.count){
                            print("idx: ")
                            print(idx)
                            self.showMessages(id: idx, data: messageDict[idx], completion: {
                                print("block complete")
                                //idx += 1
                            })
                            idx += 1
                        }

                        
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
    
    func showMessages(id: Int, data: Dictionary<String, String>, completion: @escaping () -> ()){
        print(data["sender"])
        var isSender = false;
        if (data["sender"] == SocketIOManager.sharedInstance.currUserObj.username){
            isSender = true
        }
        var profilePic: UIImage = UIImage()
        if(data["senderImg"]! == "none"){
            profilePic = UIImage(named: "profilepic_none")!
            let chatUser = ChatUser(displayName: data["sender"]!, avatar: profilePic, avatarUrl: nil, isSender: isSender)
            let body: MSGMessageBody = .text(data["message"]!)
            let message = MSGMessage(id: id, body: body, user: chatUser, sentAt: Date())
            print("adding message")
            print(data["message"]!)
            self.messages.append([message])
            self.collectionView.reloadData()
            completion()
        }
        else {
            print("need to download pic for chat")
            print(data["senderImg"])
            ImageService.getImage(withURL: data["senderImg"]!){ image in
                print("got pic for msg")
                if (image != nil){
                    profilePic = image!
                }
                else {
                    profilePic = UIImage(named: "profilepic_none")!
                }
                let chatUser = ChatUser(displayName: data["sender"]!, avatar: profilePic, avatarUrl: nil, isSender: isSender)
                let body: MSGMessageBody = .text(data["message"]!)
                let message = MSGMessage(id: id, body: body, user: chatUser, sentAt: Date())
                print("adding message")
                print(data["message"]!)
                self.messages.append([message])
                self.collectionView.reloadData()
                //DispatchQueue.main.async {
                    completion()
                //}
                
            }
        }
//        let chatUser = ChatUser(displayName: data["sender"]!, avatar: profilePic, avatarUrl: nil, isSender: isSender)
//        let body: MSGMessageBody = .text(data["message"]!)
//        let message = MSGMessage(id: 1, body: body, user: chatUser, sentAt: Date())
//        print("adding message")
//        print(data["message"]!)
//        self.messages.append([message])
//        self.collectionView.reloadData()
//        completion()
    }
    
    @objc func goback(){
        print(self.navigationController?.viewControllers.count)
        //self.navigationController?.popViewController(animated: true)
        navigationController?.dismiss(animated: true, completion: nil)
        //self.performSegue(withIdentifier: "BackToGroup", sender: self)
    }
    
    override var style: MSGMessengerStyle {
        var style = MessengerKit.Styles.travamigos
        style.inputPlaceholder = "Message"
        let greenColor = UIColor(rgb: 0x31D283)
        style.backgroundColor = .white
        style.inputViewBackgroundColor = greenColor
        style.inputPlaceholderTextColor = .white
        style.inputPlaceholder = "Type message..."
        //style.alwaysDisplayTails = true
        //style.outgoingBubbleColor = .magenta
        //style.outgoingTextColor = .black
        //style.incomingBubbleColor = .green
        //style.incomingTextColor = .yellow
        //style.backgroundColor = .orange
        //style.inputViewBackgroundColor = .purple
        return style
    }
    
    override func inputViewPrimaryActionTriggered(inputView: MSGInputView) {
        id += 1
        print(Date())
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = .short
        
        let dateString = formatter.string(from: Date())
        print(dateString)
        let body: MSGMessageBody = .text(inputView.message)
        
        let message = MSGMessage(id: id, body: body, user: currUser, sentAt: Date())
        insert(message)
        
        inputView.resignFirstResponder()
        
        SocketIOManager.sharedInstance.sendMsg(group: self.chatname, message: inputView.message, date: dateString)
        
    }
    
    override func insert(_ message: MSGMessage) {
        
        collectionView.performBatchUpdates({
            if let lastSection = self.messages.last, let lastMessage = lastSection.last, lastMessage.user.displayName == message.user.displayName {
                self.messages[self.messages.count - 1].append(message)
                
                let sectionIndex = self.messages.count - 1
                let itemIndex = self.messages[sectionIndex].count - 1
                self.collectionView.insertItems(at: [IndexPath(item: itemIndex, section: sectionIndex)])
                
            } else {
                self.messages.append([message])
                let sectionIndex = self.messages.count - 1
                self.collectionView.insertSections([sectionIndex])
            }
        }, completion: { (_) in
            self.collectionView.scrollToBottom(animated: true)
            self.collectionView.layoutTypingLabelIfNeeded()
        })
        
    }
    
    override func insert(_ messages: [MSGMessage], callback: (() -> Void)? = nil) {
        
        collectionView.performBatchUpdates({
            for message in messages {
                if let lastSection = self.messages.last, let lastMessage = lastSection.last, lastMessage.user.displayName == message.user.displayName {
                    self.messages[self.messages.count - 1].append(message)
                    
                    let sectionIndex = self.messages.count - 1
                    let itemIndex = self.messages[sectionIndex].count - 1
                    self.collectionView.insertItems(at: [IndexPath(item: itemIndex, section: sectionIndex)])
                    
                } else {
                    self.messages.append([message])
                    let sectionIndex = self.messages.count - 1
                    self.collectionView.insertSections([sectionIndex])
                }
            }
        }, completion: { (_) in
            self.collectionView.scrollToBottom(animated: false)
            self.collectionView.layoutTypingLabelIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                callback?()
            }
        })
        
    }
    
}

// MARK: - MSGDataSource

extension ChatroomViewController: MSGDataSource {
    
    func numberOfSections() -> Int {
        return messages.count
    }
    
    func numberOfMessages(in section: Int) -> Int {
        return messages[section].count
    }
    
    func message(for indexPath: IndexPath) -> MSGMessage {
        return messages[indexPath.section][indexPath.item]
    }
    
    func footerTitle(for section: Int) -> String? {
        return "Just now"
    }
    
    func headerTitle(for section: Int) -> String? {
        return messages[section].first?.user.displayName
    }
    
}
