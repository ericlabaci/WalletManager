//
//  SettingsViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/14/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController {
    @IBOutlet weak var buttonLogout: UIButton!
    
    var loginOverlay : ActivityIndicatorOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginOverlay = ActivityIndicatorOverlay.init(view: self.view)
        self.loginOverlay.label.text = "Logging out..."
        
        self.loginOverlay.hide()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController.init(title: "Are you sure you want to logout?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "Logout", style: UIAlertActionStyle.default, handler: {
            (UIAlertAction) -> Void in
            GIDSignIn.sharedInstance().disconnect()
            self.loginOverlay.show()
            
            NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.didLogout), name: Notification.Name.GoogleLogoutSuccess, object: nil)
        })
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func didLogout() {
        self.dismiss(animated: true, completion: nil)
    }
}
