//
//  MyGroupsTableViewCell.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/29/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit

class MyGroupsTableViewCell: UITableViewCell {

    @IBOutlet weak var groupName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
