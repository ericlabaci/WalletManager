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
    
    //MARK: - Variables
    var storageReference: StorageReference!
    var user: WalletManagerUser!
    
    var nameHandle: UInt?
    
    var walletNameArray: [(id: String, name: String, time: Int)] = []

    //MARK: - Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.storageReference = Storage.storage().reference().child("users").child(FirebaseUtils.getUID() ?? "")

        self.imageViewProfile.layer.masksToBounds = true
        self.imageViewProfile.layer.cornerRadius = imageViewProfile.frame.size.width / 2.0
        
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
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.labelDisplayName.alpha = 0.0
                }, completion: { (success) -> Void in
                    self.labelDisplayName.text = displayName
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.labelDisplayName.alpha = 1.0
                    })
                })
            }
        })        
//        self.databaseReference.child("messages").queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
//            self.labelMessage.text = snapshot.value as? String
//        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBActions
//    @IBAction func searchUser(_ sender: Any) {
//        if let userName = self.textFieldMessage.text {
//            if !userName.isEmpty {
//                self.textFieldMessage.text = ""
//                FirebaseUtils.databaseReference.child(FirebaseNodes.Users.Root).queryOrdered(byChild: FirebaseNodes.Users.Name).queryEqual(toValue: userName).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
//                    if snapshot.childrenCount > 0 {
//                        self.labelMessage.text = "\(snapshot.childrenCount) user\(snapshot.childrenCount > 1 ? "s" : "") found!"
//                    } else {
//                        self.labelMessage.text = "User not found!"
//                    }
//                })
//            }
//        }
//    }
//    
//    @IBAction func createTestWallet(_ sender: Any) {
//        let walletReference = FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(self.walletIDTextField.text!)
//        walletReference.child(FirebaseNodes.Wallets.Members.Root).child(FirebaseUtils.getUID()!).child(FirebaseNodes.Wallets.Members.Group).setValue("Owner")
//        walletReference.child(FirebaseNodes.Wallets.Name).setValue("Default Name")
//        walletReference.child(FirebaseNodes.Wallets.Description).setValue("Default description.")
//    }
//    
//    @IBAction func changeOtherUserGroup(_ sender: Any) {
//        let walletReference = FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(self.walletIDTextField.text!)
//        walletReference.child(FirebaseNodes.Wallets.Members.Root).child("Wy3Hz5NpAOMNJUzePg0Cg7sVeDy2").child(FirebaseNodes.Wallets.Members.Group).setValue("Member")
//    }
//    
//    @IBAction func changeWalletName(_ sender: Any) {
//        let walletReference = FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(self.walletIDTextField.text!)
//        walletReference.child(FirebaseNodes.Wallets.Name).setValue(self.walletNameTextField.text ?? "")
//        self.walletNameTextField.text = ""
//    }
//    
//    @IBAction func changeWalletDescription(_ sender: Any) {
//        let walletReference = FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(self.walletIDTextField.text!)
//        walletReference.child(FirebaseNodes.Wallets.Description).setValue(self.walletDescriptionTextField.text ?? "")
//        self.walletDescriptionTextField.text = ""
//    }
//    
//    @IBAction func changeMyPermission(_ sender: Any) {
//        let walletReference = FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(self.walletIDTextField.text!)
//        walletReference.child(FirebaseNodes.Wallets.Members.Root).child(FirebaseUtils.getUID()!).child(FirebaseNodes.Wallets.Members.Group).setValue("member")
//    }
    
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
