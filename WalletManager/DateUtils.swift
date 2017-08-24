//
//  DateUtils.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/23/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class DateUtils: NSObject {
    static func firebaseTimeToCreationTimeFormat(millis: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        let date = Date(timeIntervalSince1970: TimeInterval(millis) / 1000.0)
        
        return dateFormatter.string(from: date)
    }
}
