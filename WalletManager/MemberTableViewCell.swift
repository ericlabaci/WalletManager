//
//  MemberTableViewCell.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/24/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

let MemberTableViewCellReuseIdentifier: String! = "MemberTableViewCellReuseIdentifier"

class MemberTableViewCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet private weak var memberGroupLabel: UILabel!
    
    //MARK: - Variables
    var group: String? {
        willSet(newValue) {
            if self.memberGroupLabel != nil {
                self.memberGroupLabel.text = newValue
                if newValue == "Owner" {
                    self.memberGroupLabel.textColor = UIColor(red: 45 / 255.0, green: 175 / 255.0, blue: 47 / 255.0, alpha: 1.0)
                } else if newValue == "Member" {
                    self.memberGroupLabel.textColor = UIColor(red: 64 / 255.0, green: 83 / 255.0, blue: 249 / 255.0, alpha: 1.0)
                } else {
                    //Guest
                    self.memberGroupLabel.textColor = UIColor(red: 206 / 255.0, green: 203 / 255.0, blue: 0 / 255.0, alpha: 1.0)
                }
            }
        }
    }
    
    //MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
