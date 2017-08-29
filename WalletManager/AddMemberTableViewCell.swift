//
//  AddMemberTableViewCell.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/29/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

let AddMemberTableViewCellReuseIdentifier: String = "AddMemberTableViewCellReuseIdentifier"

class AddMemberTableViewCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    //MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
