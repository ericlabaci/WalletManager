//
//  LoginTextField.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/13/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class LoginTextField : UITextField {
    @IBOutlet public weak var nextField : LoginTextField!;
    
    override func resignFirstResponder() -> Bool {
        if nextField != nil {
            nextField.becomeFirstResponder();
        } else {
            super.resignFirstResponder();
        }
        
        return true;
    }
}
