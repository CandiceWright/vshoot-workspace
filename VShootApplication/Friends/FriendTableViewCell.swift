//
//  FriendTableViewCell.swift
//  VShootApplication
//
//  Created by Candice Wright on 12/9/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit

//create a delegate to handle when a button has been pressed in screen
protocol FriendCellDelegate { //delegate is viewcontroller
    func didTapStartVS(friendName: String);
}

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var friendPic: UIImageView!
    @IBOutlet weak var friendUsername: UILabel!
    @IBOutlet weak var startVSButton: UIButton!
    var delegate: FriendCellDelegate?
    
    @IBAction func startVS(_ sender: Any) {
        delegate?.didTapStartVS(friendName: friendUsername.text!)
    }
    
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
