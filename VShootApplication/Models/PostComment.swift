//
//  PostComment.swift
//  VShootApplication
//
//  Created by Candice Wright on 7/19/20.
//  Copyright © 2020 Candice Wright. All rights reserved.
//

import Foundation

class PostComment {
    var commentText: String
    var username: String
    var commentDate: String
    var userImageUrl: String
    var userImage: UIImage? = UIImage(named: "profilepic_none")!
    var isByCurrUser:String
    
    init(commentText:String, username:String, userImageUrl: String, commentDate: String, isByCurrUser:String) {
        self.commentText = commentText
        self.username = username
        self.userImageUrl = userImageUrl
        self.commentDate = commentDate
        self.isByCurrUser = isByCurrUser
    }
}
