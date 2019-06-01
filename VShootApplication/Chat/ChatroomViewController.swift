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

class ChatroomViewController: MSGMessengerViewController {
    
    var chatname:String = ""
    
    // Users in the chat
    
    let steve = ChatUser(displayName: "Steve", avatar: nil, avatarUrl: nil, isSender: true)
    
    let tim = ChatUser(displayName: "Tim", avatar: nil, avatarUrl: nil, isSender: false)
    
    let can = ChatUser(displayName: "Can", avatar: nil, avatarUrl: nil, isSender: false)
    
    // Messages
    
    lazy var messages: [[MSGMessage]] = {
        return [
            [
                MSGMessage(id: 1, body: .emoji("🐙💦🔫"), user: tim, sentAt: Date()),
            ],
            [
                MSGMessage(id: 2, body: .text("Yeah sure, gimme 5"), user: steve, sentAt: Date()),
                MSGMessage(id: 3, body: .text("Okay ready when you are"), user: steve, sentAt: Date())
            ],
            [
                MSGMessage(id: 1, body: .emoji("🐙💦🔫"), user: can, sentAt: Date()),
            ]
        ]
    }()
    
    // Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        title = chatname
        
//        let item = self.navigationItem.leftBarButtonItem
//        let button = item!.customView as! UIButton
//        button.setTitle("< Back", for: .normal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(goback))
        let greenColor = UIColor(rgb: 0x31D283)
        navigationItem.leftBarButtonItem?.tintColor = greenColor
        
    }
    
    @objc func goback(){
        print(self.navigationController?.viewControllers.count)
        //self.navigationController?.popViewController(animated: true)
        navigationController?.dismiss(animated: true, completion: nil)
        //self.performSegue(withIdentifier: "BackToGroup", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.navigationBar.isHidden = false
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
