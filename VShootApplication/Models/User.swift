//
//  User.swift
//  VShootApplication
//
//  Created by Candice Wright on 12/10/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import Foundation
import UIKit

class User {
    var username: String = ""
    var imageUrl: String
    var image: UIImage? = nil
    //var image = UIImage()
    var vsPreference:String = ""
    //var isFriends: Bool
    var friends = [User]()
    var groups = [Group]()
    
    init(username:String, imageUrl:String) {
        self.username = username
        self.imageUrl = imageUrl
        //self.isFriends = isFriends
    }
}
