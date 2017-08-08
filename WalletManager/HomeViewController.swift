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
        
        self.databaseReference = Database.database().reference().child("users").child(FirebaseUtils.getUID() ?? "")
        self.storageReference = Storage.storage().reference().child("users").child(FirebaseUtils.getUID() ?? "")
        
        let imageWidth = imageViewProfile.frame.size.width
        
        self.imageViewProfile.layer.masksToBounds = true
        self.imageViewProfile.layer.cornerRadius = imageWidth / 2.0
        
        self.labelDisplayName.text = user.displayName
        
        if user.accountProvider == AccountProvider.Google {
            //Check if image exists
            DebugLogger.log("Google - Verifying if user has image on firebase")
            self.storageReference?.child("profileImage").downloadURL(completion: { (url, error) -> Void in
                //If error occurs, image doesn't exist
                if error != nil {
                    //Download profile image data
                    DebugLogger.log("Google - Downloading profile image")
                    let imageData = try? Data(contentsOf: GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: 64))
                    if let imageData = imageData {
                        self.imageViewProfile.image = UIImage(data: imageData)
                        self.activityProfileImage.isHidden = true
                        //Upload to firebase
                        DebugLogger.log("Google - Uploading profile image")
                        self.storageReference?.child("profileImage").putData(imageData, metadata: nil, completion: {(storageMetadata, error) -> Void in
                            if let error = error {
                                DebugLogger.log("Google - Error uploading image: \(error.localizedDescription)")
                            } else {
                                DebugLogger.log("Google - Profile image uploaded")
                            }
                        })
                    } else {
                        DebugLogger.log("Google - Failed to download profile image")
                    }
                } else {
                    DebugLogger.log("Google - User already has a profile image")
                    self.getUserProfileImage()
                }
            })
        } else {
            self.getUserProfileImage()
        }
        
        FirebaseUtils.observeUserName(with: { (snapshot) in
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
        self.databaseReference.child("name").child("123123").childByAutoId().setValue(self.textFieldMessage.text)
        self.textFieldMessage.text = ""
    }
    
    //MARK: - Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    //MARK: - Helpers
    func getUserProfileImage() {
        FirebaseUtils.loadUserProfileImage({ (data, error) -> Void in
            self.activityProfileImage.isHidden = true
            if error != nil {
                //FIXME: Temporary image
                self.imageViewProfile.image = UIImage(named: "DefaultProfilePicture")
                return
            }
            if let data = data {
                self.imageViewProfile.image = UIImage(data: data)
            }
        })
    }
}
