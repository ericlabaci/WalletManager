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
    @IBOutlet weak var selectedImageView: UIImageView!

    //MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectedImageView.alpha = 0.0
        self.selectedImageView.tintColor = UIColor(red: 0 / 255.0, green: 155 / 255.0, blue: 2 / 255.0, alpha: 1.0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
