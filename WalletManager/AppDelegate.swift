//
//  AppDelegate.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/13/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseStorage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    var window: UIWindow?
    
    var databaseReference: DatabaseReference!
    var storageReference: StorageReference!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
//        https://github.com/firebase/firechat/blob/master/rules.json
        
        self.databaseReference = Database.database().reference()
        self.storageReference = Storage.storage().reference()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            DebugLogger.log("Login error: \(error)")
            NotificationCenter.default.post(name: Notification.Name.GoogleLoginFail, object: nil)
            return
        }

        guard let googleUser = user, let displayName = googleUser.profile.name, let email = googleUser.profile.email else {
            DebugLogger.log("Failed to get user information")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: googleUser.authentication.idToken, accessToken: googleUser.authentication.accessToken)
        
        DebugLogger.log("Logging in...")
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error = error {
                DebugLogger.log("Authentication failed with error \(error)")
                NotificationCenter.default.post(name: Notification.Name.GoogleLoginFail, object: nil)
                return
            }
            
            if let uid = user?.uid {
                let walletManagerUser = WalletManagerUser(displayName, email, uid, AccountProvider.Google)
                
                self.databaseReference?.child("users").child(uid).child("name").setValue(displayName)
                self.databaseReference?.child("users").child(uid).child("email").setValue(email)
                self.databaseReference?.child("users").child(uid).child("accountProvider").setValue(AccountProvider.Google)
                
                //Check if image exists
                self.storageReference?.child("users").child(uid).child("profileImage").downloadURL(completion: { (url, error) -> Void in
                    //If error occurs, image doesn't exist
                    if error != nil {
                        DebugLogger.log("Downloading profile image...")
                        let imageData = try? Data(contentsOf: googleUser.profile.imageURL(withDimension: 64))
                        DebugLogger.log("Uploading profile image...")
                        if let imageData = imageData {
                            self.storageReference?.child("users").child(uid).child("profileImage").putData(imageData, metadata: nil, completion: {(storageMetadata, error) -> Void in
                                if let error = error {
                                    DebugLogger.log("Error uploading image: \(error)")
                                } else {
                                    DebugLogger.log("Profile image uploaded")
                                }
                                DebugLogger.log("Successful login!\nName: \(displayName)\nE-mail: \(email)\nuID: \(uid)")
                                
                                NotificationCenter.default.post(name: Notification.Name.GoogleLoginSuccess, object: nil, userInfo: ["walletManagerUser" : walletManagerUser])
                            })
                        }
                    } else {
                        DebugLogger.log("User already has a profile image")
                        DebugLogger.log("Successful login!\nName: \(displayName)\nE-mail: \(email)\nuID: \(uid)")
                        
                        NotificationCenter.default.post(name: Notification.Name.GoogleLoginSuccess, object: nil, userInfo: ["walletManagerUser" : walletManagerUser])
                    }
                })
            } else {
                NotificationCenter.default.post(name: Notification.Name.GoogleLoginFail, object: nil)
            }
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            DebugLogger.log("Logout error: \(error!)")
            NotificationCenter.default.post(name: Notification.Name.GoogleLogoutFail, object: nil)
            return
        }

        DebugLogger.log("Loging out...")
        do {
            try Auth.auth().signOut()
            
            DebugLogger.log("Successful logout!")
            NotificationCenter.default.post(name: Notification.Name.GoogleLogoutSuccess, object: nil)
        } catch let signOutError as NSError {
            DebugLogger.log("Error logging out: \(signOutError)")
            NotificationCenter.default.post(name: Notification.Name.GoogleLogoutFail, object: nil)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

