//
//  ForumTableViewCell.swift
//  VShootApplication
//
//  Created by Candice Wright on 7/8/20.
//  Copyright © 2020 Candice Wright. All rights reserved.
//

import UIKit

protocol ForumTableViewCellDelegate: AnyObject {
    func didTapLikeBtn(rowSelected: Int, cell:ForumTableViewCell)
    func didTapCommentBtn(rowSelected: Int)
}

class ForumTableViewCell: UITableViewCell {
    var delegate: ForumTableViewCellDelegate?
    var cellRow: Int = 0
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var numLikes: UILabel!
    @IBOutlet weak var numComments: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userImg.image = nil
        self.likeBtn.imageView?.image = nil
    }
    
    @IBAction func likeBtnTapped(_ sender: Any) {
        //change button image
//        self.likeBtn.imageView?.image = UIImage(named: "heart.fill")
        delegate?.didTapLikeBtn(rowSelected: self.cellRow, cell: self)
    }
    
    @IBAction func commentBtnTapped(_ sender: Any) {
        delegate?.didTapCommentBtn(rowSelected: self.cellRow)
    }
    
    
    

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
