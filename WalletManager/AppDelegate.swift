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
    
    //MARK: - Class methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
//        https://github.com/firebase/firechat/blob/master/rules.json
        
        self.databaseReference = Database.database().reference()
        self.storageReference = Storage.storage().reference()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        return true
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

    //MARK: - Open URL
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    //MARK: - Sign in/out
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            self.googleLoginFail("Google - Login fail with error: \(error.localizedDescription)")
            return
        }
        
        //Get google user, display name and e-mail
        guard let googleUser = user, let displayName = googleUser.profile.name, let email = googleUser.profile.email else {
            self.googleLoginFail("Google - Failed to get user information")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: googleUser.authentication.idToken, accessToken: googleUser.authentication.accessToken)
        
        DebugLogger.log("Google - Logging in...")
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error = error {
                self.googleLoginFail("Google - Authentication failed with error \(error.localizedDescription)")
                return
            }
            
            guard let uid = user?.uid else {
                self.googleLoginFail("Google - User has no uid")
                return
            }
            
            //Create user
            let walletManagerUser = WalletManagerUser(displayName, email, uid, AccountProvider.Google)
            
            //Save user data to firebase
            FirebaseUtils.saveUserName(displayName)
            FirebaseUtils.saveUserEmail(email)
            FirebaseUtils.saveUserAccountProvider(AccountProvider.Google)
            
            //Check if image exists
            DebugLogger.log("Google - Verifying if user has image on firebase")
            self.storageReference?.child("users").child(uid).child("profileImage").downloadURL(completion: { (url, error) -> Void in
                //If error occurs, image doesn't exist
                if error != nil {
                    //Download profile image data
                    DebugLogger.log("Google - Downloading profile image")
                    let imageData = try? Data(contentsOf: googleUser.profile.imageURL(withDimension: 64))
                    //Upload profile image
                    DebugLogger.log("Google - Uploading profile image")
                    if let imageData = imageData {
                        self.storageReference?.child("users").child(uid).child("profileImage").putData(imageData, metadata: nil, completion: {(storageMetadata, error) -> Void in
                            if let error = error {
                                DebugLogger.log("Google - Error uploading image: \(error.localizedDescription)")
                            } else {
                                DebugLogger.log("Google - Profile image uploaded")
                            }
                            self.googleLoginSuccess("Google - Successful login!\nName: \(displayName)\nE-mail: \(email)\nuID: \(uid)", ["walletManagerUser" : walletManagerUser])
                        })
                    }
                } else {
                    DebugLogger.log("Google - User already has a profile image")
                    self.googleLoginSuccess("Google - Successful login!\nName: \(displayName)\nE-mail: \(email)\nuID: \(uid)", ["walletManagerUser" : walletManagerUser])
                }
            })
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            self.googleLogoutFail("Google - Logout error: \(error!)")
            return
        }
        
        DebugLogger.log("Google - Loging out...")
        do {
            try Auth.auth().signOut()
            
            self.googleLogoutSuccess("Google - Successful logout")
        } catch let signOutError as NSError {
            self.googleLogoutFail("Google - Error logging out: \(signOutError)")
        }
    }
    
    //MARK: - Authentication Notifications
    func googleLoginSuccess(_ successMessage: String?, _ userInfo: [AnyHashable : Any]?) {
        DebugLogger.log(successMessage)
        NotificationCenter.default.post(name: Notification.Name.GoogleLoginSuccess, object: nil, userInfo: userInfo)
    }
    
    func googleLoginFail(_ errorMessage: String?) {
        DebugLogger.log(errorMessage)
        NotificationCenter.default.post(name: Notification.Name.GoogleLoginFail, object: nil)
    }
    
    func googleLogoutSuccess(_ successMessage: String?) {
        DebugLogger.log(successMessage)
        NotificationCenter.default.post(name: Notification.Name.GoogleLogoutSuccess, object: nil)
    }
    
    func googleLogoutFail(_ errorMessage: String?) {
        DebugLogger.log(errorMessage)
        NotificationCenter.default.post(name: Notification.Name.GoogleLogoutFail, object: nil)
    }
}

