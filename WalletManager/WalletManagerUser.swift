//
//  WalletManagerUser.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/20/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

class WalletManagerUser: NSObject {
    var displayName: String
    var email: String
    var accountProvider: String
    
    init(_ displayName: String, _ email: String, _ accountProvider: String) {
        self.displayName = displayName
        self.email = email
        self.accountProvider = accountProvider
    }
}
