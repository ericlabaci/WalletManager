//
//  LoginViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/13/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonRegister: UIButton!
    @IBOutlet weak var textFieldEmail: LoginTextField!
    @IBOutlet weak var textFieldPassword: LoginTextField!
    
    var loginOverlay : ActivityIndicatorOverlay!

    override func viewDidLoad() {
        super.viewDidLoad()

        googleSignInButton.style = GIDSignInButtonStyle.wide
        googleSignInButton.colorScheme = GIDSignInButtonColorScheme.light

        GIDSignIn.sharedInstance().uiDelegate = self

        self.loginOverlay = ActivityIndicatorOverlay.init(view: self.view)
        self.loginOverlay.onHide = {
            () -> Void in
            self.googleSignInButton.isEnabled = true
            self.buttonLogin.isEnabled = true
            self.buttonRegister.isEnabled = true
            self.textFieldEmail.isEnabled = true
            self.textFieldPassword.isEnabled = true
        }
        self.loginOverlay.onShow = {
            () -> Void in
            self.googleSignInButton.isEnabled = false
            self.buttonLogin.isEnabled = false
            self.buttonRegister.isEnabled = false
            self.textFieldEmail.isEnabled = false
            self.textFieldPassword.isEnabled = false
        }
        self.loginOverlay.label.text = "Authenticating..."
        
        self.loginOverlay.hide()
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
            self.loginOverlay.show()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.didLogin), name: Notification.Name.GoogleLoginSuccess, object: nil)
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

    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
        self.loginOverlay.show()
    }
    
    func didLogin() {
        let storyboard : UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil);
        let viewController : UIViewController = storyboard.instantiateInitialViewController()!
        
        self.present(viewController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.loginOverlay.hide()
        }
    }
}
