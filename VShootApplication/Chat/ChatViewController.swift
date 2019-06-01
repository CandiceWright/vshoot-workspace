//
//  ChatViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/30/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import MessengerKit

class ChatViewController: MSGMessengerViewController {
    
    // Users in the chat
    
    let steve = ChatUser(displayName: "Steve", avatar: #imageLiteral(resourceName: "steve228uk"), avatarUrl: nil, isSender: true)
    
    let tim = ChatUser(displayName: "Tim", avatar: #imageLiteral(resourceName: "timi"), avatarUrl: nil, isSender: false)
    
    // Messages
    
    lazy var messages: [[MSGMessage]] = {
        return [
            [
                MSGMessage(id: 1, body: .emoji("🐙💦🔫"), user: tim, sentAt: Date()),
            ],
            [
                MSGMessage(id: 2, body: .text("Yeah sure, gimme 5"), user: steve, sentAt: Date()),
                MSGMessage(id: 3, body: .text("Okay ready when you are"), user: steve, sentAt: Date())
            ]
        ]
    }()
    
    // Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        dataSource = self
        
    }
    
}

// MARK: - MSGDataSource

extension ChatViewController: MSGDataSource {
    
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
