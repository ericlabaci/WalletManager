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
        self.loginOverlay.onHide = {
            () -> Void in
            let arrayOfTabBarItems = self.tabBarController?.tabBar.items as AnyObject as? NSArray
            for tabBarItem in arrayOfTabBarItems! {
                let item = tabBarItem as? UITabBarItem
                item!.isEnabled = true
            }
            self.buttonLogout.isEnabled = true
        }
        self.loginOverlay.onShow = {
            () -> Void in
            let arrayOfTabBarItems = self.tabBarController?.tabBar.items as AnyObject as? NSArray
            for tabBarItem in arrayOfTabBarItems! {
                let item = tabBarItem as? UITabBarItem
                item!.isEnabled = false
            }
            self.buttonLogout.isEnabled = false
        }
        self.loginOverlay.label.text = "Logging out..."
        
        self.loginOverlay.hide()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logout(_ sender: Any) {
        GIDSignIn.sharedInstance().disconnect()
        self.loginOverlay.show()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.didLogout), name: Notification.Name.GoogleLogoutSuccess, object: nil)
    }
    
    func didLogout() {
        self.dismiss(animated: true, completion: nil)
    }
}
