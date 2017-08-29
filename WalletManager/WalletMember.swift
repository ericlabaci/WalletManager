//
//  Member.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/25/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class WalletMember: NSObject {
    var id: String
    var name: String
    var group: String
    
    init(id:String, name: String, group: String) {
        self.id = id
        self.name = name
        self.group = group
        super.init()
    }
}
