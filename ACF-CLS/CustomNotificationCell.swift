//
//  CustomTableViewCell.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 4/21/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import UIKit

class CustomNotificationCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
