//
//  RegisterViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/19/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit
import FirebaseStorage

protocol RegisterViewControllerDelegate {
    func didCreateAccount(_ user: WalletManagerUser)
}

class RegisterViewController : UIViewController {
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    
    var delegate: RegisterViewControllerDelegate?
    
    var databaseReference: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.databaseReference = Database.database().reference()
    }
    
    @IBAction func register(_ sender: Any) {
        if (self.textFieldEmail.text?.characters.count)! <= 0 {
            let alertController = UIAlertController(title: "Error creating account", message: "Please enter an e-mail.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        } else if (self.textFieldName.text?.characters.count)! <= 0 {
            let alertController = UIAlertController(title: "Error creating account", message: "Please enter your name.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        Auth.auth().createUser(withEmail: self.textFieldEmail.text!, password: self.textFieldPassword.text!, completion: {(user, error) -> Void in
            if let error = error {
                DebugLogger.log("\(error)")
                
                let alertController = UIAlertController(title: "Error creating account", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            let displayName = self.textFieldName.text!
            let email = user?.email ?? "No data"
            let uid = user?.uid ?? "No uid"
            
            self.databaseReference.child("users").child(uid).child("name").setValue(displayName)
            self.databaseReference.child("users").child(uid).child("email").setValue(email)
            self.databaseReference.child("users").child(uid).child("accountProvider").setValue(AccountProvider.WalletManager)
            
            DebugLogger.log("Successful login!\nName: \(displayName)\nE-mail: \(email)\nuID: \(uid)")
            
            self.dismiss(animated: true, completion: nil)
            self.delegate?.didCreateAccount(WalletManagerUser(displayName, email, uid, AccountProvider.WalletManager))
        })
    }
}
