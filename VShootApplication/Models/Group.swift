//
//  Group.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/24/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import Foundation
import UIKit

class Group {
    var name: String = ""
    var creator: String = ""
    var description: String
    var members = [User]()
    
    init(name:String, creator:String, description:String) {
        self.name = name
        self.creator = creator
        self.description = description
    }
}
