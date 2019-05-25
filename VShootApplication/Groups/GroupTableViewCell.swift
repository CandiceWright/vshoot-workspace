//
//  GroupTableViewCell.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/24/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gName: UILabel!
    @IBOutlet weak var gDescr: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
