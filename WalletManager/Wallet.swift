//
//  Wallet.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/28/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class Wallet: NSObject {
    var id: String
    var name: String
    var descr: String
    var time: Int
    
    init(id:String, name: String, description: String, time: Int) {
        self.id = id
        self.name = name
        self.descr = description
        self.time = time
        super.init()
    }
}
