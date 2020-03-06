//
//  VShoot.swift
//  VShootApplication
//
//  Created by Candice Wright on 3/3/20.
//  Copyright © 2020 Candice Wright. All rights reserved.
//

import Foundation
import UIKit

class VShoot {
    var photographer:String = ""
    var photoUrls:[String] = [String]()
    var coverPhoto:UIImage = UIImage()
    var cost:Double = 0.0
    var numPhotos: Int = 0
    var duration: Double = 0.0
    var date:String = ""
    
//    init(photographer: String, photoUrls:[String], coverPhoto:UIImage, cost: Double, numPhotos: Int, duration: Double, date: String) {
//        self.photographer = photographer
//        self.photoUrls = photoUrls
//        self.coverPhoto = coverPhoto
//        self.cost = cost
//        self.numPhotos = numPhotos
//        self.duration = duration
//        self.date = date
//    }
    
    init(coverPhoto:UIImage, date: String) {
        
        self.coverPhoto = coverPhoto
        self.date = date
    }
}
