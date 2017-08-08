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
    //MARK: - IBOutlets
    @IBOutlet weak var buttonLogout: UIButton!
    
    //MARK: - Variables
    var loginOverlay : ActivityIndicatorOverlay!
    
    var databaseReference: DatabaseReference!
    var user: WalletManagerUser!
    
    var stateListenerBlock: AuthStateDidChangeListenerBlock!
    var stateListenerHandle: AuthStateDidChangeListenerHandle!
    
    //MARK: - Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.databaseReference = Database.database().reference()
        
        self.loginOverlay = ActivityIndicatorOverlay.init(view: (self.tabBarController?.view)!)
        self.loginOverlay.label.text = "Signing out..."
        
        self.loginOverlay.hide()
        
        self.stateListenerBlock = { (auth, user) -> Void in
            if auth.currentUser == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: { () -> Void in
                    self.logoutSuccess()
                })
            } else {
                self.logoutFail()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - IBActions
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController.init(title: "Are you sure you want to logout?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "Logout", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
            self.loginOverlay.show()
            
            do {
                self.databaseReference.child("users").child(FirebaseUtils.getUID() ?? "").child("name").removeAllObservers()
                self.databaseReference.child("users").child(FirebaseUtils.getUID() ?? "").child("messages").removeAllObservers()

                switch self.user.accountProvider {
                case AccountProvider.Facebook:
                    
                    break
                    
                case AccountProvider.Google:
                    GIDSignIn.sharedInstance().disconnect()
//                    NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.logoutSuccess), name: Notification.Name.GoogleLogoutSuccess, object: nil)
//                    NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.logoutFail), name: Notification.Name.GoogleLogoutFail, object: nil)
                    break
                    
                case AccountProvider.WalletManager:
                    break
                    
                default:
                    break
                }
                
                self.stateListenerHandle = Auth.auth().addStateDidChangeListener(self.stateListenerBlock)
                try Auth.auth().signOut()
            } catch let error {
                DebugLogger.log("Auth - Error signing out \(error.localizedDescription)")
            }
        })
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Log in/out
    func logoutSuccess() {
        DebugLogger.log("Auth - Successful logout")
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
        () -> Void in
            self.loginOverlay.hide()
        })
        Auth.auth().removeStateDidChangeListener(self.stateListenerHandle)
    }
    
    func logoutFail() {
        DebugLogger.log("Auth - Failed logout")
        self.loginOverlay.hide()
        Auth.auth().removeStateDidChangeListener(self.stateListenerHandle)
    }
}
