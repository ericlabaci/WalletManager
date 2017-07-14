//
//  LoginViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/13/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class HomeViewController : UIViewController, UITextFieldDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let loginTextField : LoginTextField = textField as? LoginTextField {
            return loginTextField.resignFirstResponder()
        }
        
        return true
    }
    
    @IBAction func logout(_ sender: Any) {
        GIDSignIn.sharedInstance().disconnect()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.didLogout), name: Notification.Name.GoogleLogoutSuccess, object: nil)
    }
    
    func didLogout() {
        self.dismiss(animated: true, completion: nil)
    }
}
