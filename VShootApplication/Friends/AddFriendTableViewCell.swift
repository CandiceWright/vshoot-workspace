//
//  AddFriendTableViewCell.swift
//  VShootApplication
//
//  Created by Candice Wright on 12/10/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit

protocol AddFriendCellDelegate { //delegate is viewcontroller
    func didTapAddFriend(username: String);
}

class AddFriendTableViewCell: UITableViewCell {

    @IBOutlet weak var friendPic: UIImageView!
    @IBOutlet weak var friendUsername: UILabel!
    var delegate: AddFriendCellDelegate?
    //probably get rid of the button in the cell and just make cells clickable and open a popover to add/remove friend
//    @IBAction func addFriend(_ sender: Any) {
//        delegate?.didTapAddFriend(username: friendUsername.text!)
//    }
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
            self.friendPic.image = image
            self.friendPic.layer.cornerRadius = self.friendPic.frame.height/2
            self.friendPic.clipsToBounds = true
            self.friendPic.layer.masksToBounds = true
        }
    }

}
