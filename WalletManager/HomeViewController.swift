//
//  LoginViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/13/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseStorage

class HomeViewController : UIViewController, UITextFieldDelegate {
    //MARK: - IBOutlets
    @IBOutlet weak var labelDisplayName: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var activityProfileImage: UIActivityIndicatorView!
    
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var textFieldMessage: UITextField!
    
    //MARK: - Variables
    var databaseReference: DatabaseReference!
    var storageReference: StorageReference!
    var user: WalletManagerUser!
    
    //MARK: - Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.databaseReference = Database.database().reference().child("users").child(self.user.uid)
        self.storageReference = Storage.storage().reference().child("users").child(self.user.uid)
        
        let imageWidth = imageViewProfile.frame.size.width
        
        self.imageViewProfile.layer.masksToBounds = true
        self.imageViewProfile.layer.cornerRadius = imageWidth / 2.0
        
        self.storageReference.child("profileImage").getData(maxSize: 5000000, completion: {(data, error) -> Void in
            self.activityProfileImage.isHidden = true
            if let error = error {
                DebugLogger.log("Firebase - Profile image download error: \(error.localizedDescription)")
                //FIXME: Temporary image
                self.imageViewProfile.image = UIImage(named: "DefaultProfilePicture")
                return
            }
            if let data = data {
                self.imageViewProfile.image = UIImage(data: data)
            }
        })
        
        self.databaseReference.child("name").observe(.value, with: { (snapshot) in
            if let displayName = snapshot.value as? String {
                self.user.displayName = displayName
                self.labelDisplayName.text = displayName
            }
        })
        
        self.databaseReference.child("messages").queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
            self.labelMessage.text = snapshot.value as? String
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK - IBActions
    @IBAction func sendMessage(_ sender: Any) {
        self.databaseReference.child("abacaxinaofazxixi").childByAutoId().setValue(self.textFieldMessage.text)
        self.textFieldMessage.text = ""
    }
    
    //MARK: - Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
