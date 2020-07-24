//
//  ForumPost.swift
//  VShootApplication
//
//  Created by Candice Wright on 7/10/20.
//  Copyright © 2020 Candice Wright. All rights reserved.
//

import Foundation

class ForumPost {
    var forumId: Int
    var postText: String
    var username: String
    var datePosted: String
    var numLikes: Int
    var didLikePost: String
    var numComments: Int
    var imageUrl: String
    var image: UIImage? = UIImage(named: "profilepic_none")!
    
    init(forumId: Int, postText:String, username:String, imageUrl: String, datePosted: String, numLikes: Int, numComments: Int, didLikePost: String) {
        self.didLikePost = didLikePost
        self.forumId = forumId
        self.postText = postText
        self.username = username
        self.imageUrl = imageUrl
        self.datePosted = datePosted
        self.numLikes = numLikes
        self.numComments = numComments
        //self.isFriends = isFriends
    }
}
