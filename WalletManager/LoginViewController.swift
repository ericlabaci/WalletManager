//
//  LoginViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/13/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate, GIDSignInUIDelegate {
    //MARK: - IBOutlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var emailTextFieldView: LoginTextFieldView!
    @IBOutlet weak var passwordTextFieldView: LoginTextFieldView!
    @IBOutlet weak var nameTextFieldView: LoginTextFieldView!
    
    @IBOutlet weak var googleSignInView: UIView!
    @IBOutlet weak var registerFieldsView: UIView!
    
    //MARK: - Constraints
    @IBOutlet weak var emailViewCenterYConstraint: NSLayoutConstraint!
    
    //MARK: - Variables
    var loginOverlay: ActivityIndicatorOverlay!
    
    var isRegistering: Bool = false
    
    //MARK: - Original Values
    var emailViewCenterYOriginalConstant: CGFloat!
    var loginButtonLabelTextOriginal: String!
    var registerButtonLabelTextOriginal: String!

    //MARK: - Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundImageView.alpha = 1.0
        self.backgroundImageView.addBlurEffect()
        
        self.emailTextFieldView.backgroundColor = UIColor.clear
        self.passwordTextFieldView.backgroundColor = UIColor.clear
        self.googleSignInView.backgroundColor = UIColor.clear
        self.registerFieldsView.backgroundColor = UIColor.clear
        self.registerFieldsView.alpha = 0.0
        
        self.emailViewCenterYOriginalConstant = self.emailViewCenterYConstraint.constant
        
        self.loginButtonLabelTextOriginal = self.loginButton.title(for: .normal)
        self.registerButtonLabelTextOriginal = self.registerButton.title(for: .normal)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeKeyboard)))
        
        let emailTextFieldViewDictionary: [LoginTextFieldViewProperties : Any?] = [.PlaceholderText : "E-mail",
                                                                                  .Icon : UIImage(named: "EmailLoginIcon") as Any,
                                                                                  .KeyboardType : UIKeyboardType.emailAddress as Any,
                                                                                  .ReturnKey: UIReturnKeyType.next as Any,
                                                                                  .Secure : false,
                                                                                  .TextFieldNext : self.passwordTextFieldView,
                                                                                  .TextFieldDelegate : self,
                                                                                  .TextFieldIdentifier : "E-mail"];
        self.emailTextFieldView.setProperties(emailTextFieldViewDictionary)
        
        let passwordTextFieldViewDictionary: [LoginTextFieldViewProperties : Any?] = [.PlaceholderText : "Password",
                                                                                      .Icon : UIImage(named: "PasswordLoginIcon") as Any,
                                                                                      .KeyboardType : UIKeyboardType.default as Any,
                                                                                      .ReturnKey: UIReturnKeyType.go as Any,
                                                                                      .Secure : true,
                                                                                      .TextFieldNext : nil,
                                                                                      .TextFieldDelegate : self,
                                                                                      .TextFieldIdentifier : "Password"];
        self.passwordTextFieldView.setProperties(passwordTextFieldViewDictionary)
        
        let nameTextFieldViewDictionary: [LoginTextFieldViewProperties : Any?] = [.PlaceholderText : "Name",
                                                                                  .Icon : nil,
                                                                                  .KeyboardType : UIKeyboardType.default as Any,
                                                                                  .ReturnKey: UIReturnKeyType.go as Any,
                                                                                  .Secure : false,
                                                                                  .TextFieldNext : nil,
                                                                                  .TextFieldDelegate : self,
                                                                                  .TextFieldIdentifier : "Name"];
        self.nameTextFieldView.setProperties(nameTextFieldViewDictionary)

        //Set GoogleSignIn delegate
        GIDSignIn.sharedInstance().uiDelegate = self

        //Initialize LoginOverlay
        self.loginOverlay = ActivityIndicatorOverlay.init(view: self.view)
        self.loginOverlay.hide()
        
        //Check if user is already signed in
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
            self.loginOverlay.label.text = "Logging in..."
            self.loginOverlay.show()
        } else if let user = Auth.auth().currentUser {
            guard let email = user.email else {
                DebugLogger.log("AutoAuth - Failed to get user info")
                return
            }
            self.loginOverlay.label.text = "Logging in..."
            self.loginOverlay.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {() -> Void in
                self.loginSuccess(WalletManagerUser("", email, AccountProvider.WalletManager))
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
    
    //MARK: - IBActions
    @IBAction func loginButtonAction(_ sender: Any) {
        if self.isRegistering {
            register()
        } else {
            login()
        }
    }
    
    @IBAction func registerButtonAction(_ sender: Any) {
        self.setRegistering(!self.isRegistering)
    }
    
    @IBAction func googleSignIn(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func facebookSignIn(_ sender: Any) {
        DebugLogger.log("Todo: Facebook SignIn")
    }
    
    //MARK: - Buttons
    func login() {
        let alertController = UIAlertController(title: "Error signing in", message: "", preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertController.addAction(actionOK)
        
        //Unwrap email and password
        guard let email = self.emailTextFieldView.getText(), let password = self.passwordTextFieldView.getText() else {
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
        
        self.loginOverlay.label.text = "Logging in..."
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
                guard let email = user?.email else {
                    DebugLogger.log("Auth - Failed to get user info")
                    return
                }
                
                FirebaseUtils.loadUserName({ (name) -> Void in
                    self.loginSuccess(WalletManagerUser(name ?? "", email, AccountProvider.WalletManager))
                })
            }
        })
    }
    
    func register() {
        guard let email = self.emailTextFieldView.getText(),
              let password = self.passwordTextFieldView.getText(),
              let name = self.nameTextFieldView.getText() else {
              return
        }
        
        if email.characters.count <= 0 {
            let alertController = UIAlertController(title: "Error creating account", message: "Please enter an e-mail.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        } else if name.characters.count <= 0 {
            let alertController = UIAlertController(title: "Error creating account", message: "Please enter your name.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        self.loginOverlay.label.text = "Registering..."
        self.loginOverlay.show()
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) -> Void in
            self.loginOverlay.hide()
            if let error = error {
                DebugLogger.log("\(error.localizedDescription)")
                
                self.loginOverlay.hide()
                
                let alertController = UIAlertController(title: "Error creating account", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            let displayName = name
            let email = user?.email ?? "No data"
            let uid = user?.uid ?? "No uid"
            
            FirebaseUtils.saveUserName(displayName)
            FirebaseUtils.saveUserEmail(email)
            FirebaseUtils.saveUserAccountProvider(AccountProvider.WalletManager)
            
            DebugLogger.log("Auth - Successful login!\nName: \(displayName)\nE-mail: \(email)\nuID: \(uid)")
            
            self.dismiss(animated: true, completion: nil)
            self.loginSuccess(WalletManagerUser(displayName, email, AccountProvider.WalletManager))
            self.setRegistering(false)
        })
    }

    
    //MARK: - Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let loginTextField = textField as? LoginTextField else {
            return true
        }
        
        if let nextField = loginTextField.nextField {
            nextField.becomeFirstResponder()
        } else {
            loginTextField.resignFirstResponder()
            self.loginButton.sendActions(for: .touchUpInside)
        }

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let loginTextField = textField as? LoginTextField {
            if loginTextField.identifier == "E-mail" {
                self.IsEmailRegistered(loginTextField.text, { (registered) -> Void in
                    self.setRegistering(!registered)
                })
            }
        }
    }

    //MARK: - GIDSignInUI Delegate
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
        self.loginOverlay.label.text = "Logging in..."
        self.loginOverlay.show()
    }
    
    //MARK: - Utils
    func closeKeyboard() {
        self.view.endEditing(true)
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
            self.emailTextFieldView.setText("")
            self.passwordTextFieldView.setText("")
            self.nameTextFieldView.setText("")
        }
    }
    
    func loginFail() {
        self.loginOverlay.hide()
    }
    
    //MARK: - E-mail
    func IsEmailRegistered(_ email: String!, _ completion: @escaping (Bool) -> Void) -> Void {
        //Get number of providers (if providers == 0 account doesn't exist?)
        DebugLogger.log("Fetching...")
        Auth.auth().fetchProviders(forEmail: email, completion: { (array, error) -> Void in
            if let error = error {
                DebugLogger.log("Fetching providers error: \(error.localizedDescription)")
                return
            }
            if let array = array {
                DebugLogger.log("Fetched \(array.count) provider(s)")
                completion(array.count > 0)
            } else {
                DebugLogger.log("No providers fetched")
                completion(false)
            }
        })
    }
    
    //MARK: - UI Animations
    func setRegistering(_ registering: Bool) {
        let duration = 0.6
        self.isRegistering = registering

        if self.isRegistering {
            self.emailViewCenterYConstraint.constant = -128.0
            self.loginButton.setTitle("Register", for: .normal)
            
            self.registerButton.setTitle("Cancel", for: .normal)
            
            self.passwordTextFieldView.setNextTextField(self.nameTextFieldView)
            self.passwordTextFieldView.setReturnKey(.next)
            
            self.nameTextFieldView.setText("")
        } else {
            self.emailViewCenterYConstraint.constant = self.emailViewCenterYOriginalConstant
            self.loginButton.setTitle(self.loginButtonLabelTextOriginal, for: .normal)
            
            self.registerButton.setTitle(self.registerButtonLabelTextOriginal, for: .normal)
            
            self.passwordTextFieldView.setNextTextField(nil)
            self.passwordTextFieldView.setReturnKey(.go)
        }
        self.passwordTextFieldView.loginTextField.reloadInputViews()
        UIView.animate(withDuration: duration, animations: { () -> Void in
            if self.isRegistering {
                self.googleSignInView.alpha = 0.0
            } else {
                self.registerFieldsView.alpha = 0.0
            }
            self.view.layoutIfNeeded()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
            UIView.animate(withDuration: duration, animations: { () -> Void in
                if self.isRegistering {
                    self.registerFieldsView.alpha = 1.0
                } else {
                    self.googleSignInView.alpha = 1.0
                }
            })
        })
    }
}
