//
//  GroupMemberTableViewCell.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/29/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit

class GroupMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPic(url:String){
        //        ImageService.downloadImage(myUrl: url){ image in
        //            self.friendPic.image = image
        //        }
        ImageService.getImage(withURL: url){ image in
            self.userImg.image = image
            self.userImg.layer.cornerRadius = self.userImg.frame.height/2
            self.userImg.clipsToBounds = true
            self.userImg.layer.masksToBounds = true
        }
    }

}
