//
//  VSTableViewCell.swift
//  VShootApplication
//
//  Created by Princess Candice on 10/7/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit

class VSTableViewCell: UITableViewCell {

    
    @IBOutlet weak var VSName: UILabel!
    @IBOutlet weak var VSCoverPhoto: UIImageView!
    
    @IBAction func showVSDetails(_ sender: Any) {
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
