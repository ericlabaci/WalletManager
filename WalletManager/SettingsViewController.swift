//
//  SettingsViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/14/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit
import FirebaseStorage

class SettingsViewController : UIViewController {
    @IBOutlet weak var buttonLogout: UIButton!
    
    var loginOverlay : ActivityIndicatorOverlay!
    
    var databaseReference: DatabaseReference!
    var uid: String!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.databaseReference = Database.database().reference()
        self.uid = Auth.auth().currentUser?.uid
        
        self.loginOverlay = ActivityIndicatorOverlay.init(view: (self.tabBarController?.view)!)
        self.loginOverlay.label.text = "Signing out..."
        
        self.loginOverlay.hide()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController.init(title: "Are you sure you want to logout?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "Logout", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
            self.loginOverlay.show()
            
            if GIDSignIn.sharedInstance().currentUser != nil {
                GIDSignIn.sharedInstance().disconnect()
                NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.logoutSuccess), name: Notification.Name.GoogleLogoutSuccess, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.logoutFail), name: Notification.Name.GoogleLogoutFail, object: nil)
            }
            
            do {
                if let uid = self.uid {
                    self.databaseReference.child("users").child(uid).child("name").removeAllObservers()
                    self.databaseReference.child("users").child(uid).child("messages").removeAllObservers()
                }
                
                try Auth.auth().signOut()
            } catch let error {
                DebugLogger.log("Error signing out \(error.localizedDescription)")
            }
        })
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func logoutSuccess() {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
        () -> Void in
            self.loginOverlay.hide()
        })
    }
    
    func logoutFail() {
        self.loginOverlay.hide()
    }
}
