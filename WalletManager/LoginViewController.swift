//
//  LoginViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/13/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, RegisterViewControllerDelegate {
    //MARK: - IBOutlets
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonRegister: UIButton!
    @IBOutlet weak var textFieldEmail: LoginTextField!
    @IBOutlet weak var textFieldPassword: LoginTextField!
    
    //MARK: - Variables
    var loginOverlay: ActivityIndicatorOverlay!
    var databaseReference: DatabaseReference!

    //MARK: - Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.databaseReference = Database.database().reference()
        
        //Set Google sign in button style
        self.googleSignInButton.style = GIDSignInButtonStyle.wide
        self.googleSignInButton.colorScheme = GIDSignInButtonColorScheme.light
        
        //Set Facebook sign in button style

        //Set GoogleSignIn delegate
        GIDSignIn.sharedInstance().uiDelegate = self

        //Initialize LoginOverlay
        self.loginOverlay = ActivityIndicatorOverlay.init(view: self.view)
        self.loginOverlay.label.text = "Signing in..."
        self.loginOverlay.hide()
        
        //Check if user is already signed in
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
            self.loginOverlay.show()
        } else if let user = Auth.auth().currentUser {
            guard let email = user.email else {
                DebugLogger.log("AutoAuth - Failed to get user info")
                return
            }
            self.loginOverlay.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {() -> Void in
                self.loginSuccess(WalletManagerUser("", email, user.uid, AccountProvider.WalletManager))
            })
        }

        NotificationCenter.default.addObserver(forName: Notification.Name.GoogleLoginSuccess, object: nil, queue: nil, using: { (notification) -> Void in
            if let user = notification.userInfo?["walletManagerUser"] as? WalletManagerUser {
                self.loginSuccess(user)
            }
        })
        
        NotificationCenter.default.addObserver(forName: Notification.Name.GoogleLoginFail, object: nil, queue: nil, using: { (notification) -> Void in
            self.loginFail()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegisterViewControllerSegue" {
            let vc = segue.destination as? RegisterViewController
            vc?.delegate = self
        }
    }
    
    //MARK: - IBActions
    @IBAction func login() {
        let alertController = UIAlertController(title: "Error signing in", message: "", preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertController.addAction(actionOK)
        
        //Unwrap email and password
        guard let email = self.textFieldEmail.text, let password = self.textFieldPassword.text else {
            alertController.message = "An unexpected error ocurred. Please try again."
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        //Check if user entered an e-mail
        if email.characters.count <= 0 {
            alertController.message = "Please enter an e-mail."
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        //Check if user enter a password
        if password.characters.count <= 0 {
            alertController.message = "Please enter a password."
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        self.loginOverlay.show()
        
        //Authenticate user
        DebugLogger.log("Auth - Authenticating with <\(email)>")
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) -> Void in
            //Check if user was authenticated
            if let error = error {
                DebugLogger.log("Auth - Authentication failed with error: \(error.localizedDescription)")
                
                self.loginOverlay.hide()
                
                alertController.message = error.localizedDescription
                self.present(alertController, animated: true, completion: nil)
            } else {
                DebugLogger.log("Auth - Authentication successful")
                //Get e-mail and uid
                guard let email = user?.email, let uid = user?.uid else {
                    DebugLogger.log("Auth - Failed to get user info")
                    return
                }
                
                self.loginSuccess(WalletManagerUser("", email, uid, AccountProvider.WalletManager))
            }
        })
    }
    
    //MARK: - Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let loginTextField = textField as? LoginTextField {
            if let nextField = loginTextField.nextField {
                nextField.becomeFirstResponder()
            } else {
                loginTextField.resignFirstResponder()
                self.login()
            }
        }

        return true
    }

    //MARK: - GIDSignInUI Delegate
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
        self.loginOverlay.show()
    }
    
    //MARK: - RegisterViewController Delegate
    func didCreateAccount(_ user: WalletManagerUser) {
        self.loginOverlay.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: { () -> Void in
            self.loginSuccess(user)
        })
    }
    
    //MARK: - Login
    func loginSuccess(_ user: WalletManagerUser) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateInitialViewController(),
              let homeVC = tabBarController.childViewControllers[0].childViewControllers[0] as? HomeViewController,
              let settingsVC = tabBarController.childViewControllers[2].childViewControllers[0] as? SettingsViewController else {
            return
        }
        
        homeVC.user = user
        settingsVC.user = user
        self.present(tabBarController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.loginOverlay.hide()
            self.textFieldEmail.text = ""
            self.textFieldPassword.text = ""
        }
    }
    
    func loginFail() {
        self.loginOverlay.hide()
    }
    
    //FIXME: Fix async process
    func isEmailRegistered(_ email: String!, _ completion: @escaping (Bool) -> Void) -> Void {
        //Get number of providers (if providers == 0 account doesn't exist?)
        DebugLogger.log("Fetching...")
        Auth.auth().fetchProviders(forEmail: email, completion: { (array, error) -> Void in
            if let error = error {
                DebugLogger.log("Fetching providers error: \(error.localizedDescription)")
                completion(false)
                return
            }
            if let array = array {
                completion(array.count > 0)
            } else {
                completion(false)
            }
        })
    }
}
