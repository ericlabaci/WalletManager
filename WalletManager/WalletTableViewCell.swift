//
//  WalletTableViewCell.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/24/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

let WalletTableViewCellReuseIdentifier: String! = "WalletTableViewCellReuseIdentifier"

class WalletTableViewCell: UITableViewCell {
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet private weak var createdAtLabel: UILabel!

    //MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Utils
    func setCreationDateLabel(creationDate: String) {
        self.createdAtLabel.text = "Created at\n\(creationDate)"
    }
}
