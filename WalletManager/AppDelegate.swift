//
//  AppDelegate.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/13/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        //        https://firebase.google.com/docs/auth/ios/google-signin?hl=pt-br
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if error != nil {
            print("Login error: \(error!)")
            NotificationCenter.default.post(name: Notification.Name.GoogleLoginFail, object: nil)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential, completion: {
            (user, error) in
            if let error = error {
                print("Authentication failed with error \(error)")
                NotificationCenter.default.post(name: Notification.Name.GoogleLoginFail, object: nil)
                return
            }
      
            let displayName = user?.displayName ?? "No data"
            let email = user?.email ?? "No data"
            
            print("Successful login!\nName: \(displayName)\nE-mail: \(email)")
            
            NotificationCenter.default.post(name: Notification.Name.GoogleLoginSuccess, object: nil)
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print("Logout error: \(error!)")
            NotificationCenter.default.post(name: Notification.Name.GoogleLogoutFail, object: nil)
            return
        }
        
        let firebaseAuth = Auth.auth()
        do {
            let user = Auth.auth().currentUser
            
            let displayName = user?.displayName ?? "No data"
            let email = user?.email ?? "No data"
            
            try firebaseAuth.signOut()
            
            print("Successful logout!\nName: \(displayName)\nE-mail: \(email)")
            
            NotificationCenter.default.post(name: Notification.Name.GoogleLogoutSuccess, object: nil)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
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

