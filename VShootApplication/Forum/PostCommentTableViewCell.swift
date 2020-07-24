//
//  PostCommentTableViewCell.swift
//  VShootApplication
//
//  Created by Candice Wright on 7/19/20.
//  Copyright © 2020 Candice Wright. All rights reserved.
//

import UIKit

class PostCommentTableViewCell: UITableViewCell, UITextViewDelegate {
    var cellRow: Int = 0
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentTxtHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commentTxt.isScrollEnabled = false
        commentTxt.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userImg.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
