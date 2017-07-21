//
//  DebugLog.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/20/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

class DebugLogger {
    static func log(_ message: String?) -> Void {
        #if DEBUG
        if let message = message {
            print("DEBUG: \(message)")
        }
        #endif
    }
}
