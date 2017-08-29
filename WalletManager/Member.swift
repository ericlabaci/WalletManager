//
//  Member.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/29/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class Member: NSObject {
    var id: String
    var name: String
    var email: String
    
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
        super.init()
    }
}
