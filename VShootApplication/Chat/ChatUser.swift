//
//  ChatUser.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/30/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import Foundation
import MessengerKit
import UIKit

struct ChatUser: MSGUser {
    
    var displayName: String
    
    var avatar: UIImage?
    
    var avatarUrl: URL?
    
    var isSender: Bool
    
}
