//
//  LoginViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/13/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController : UIViewController, UITextFieldDelegate {
    @IBOutlet weak var labelDisplayName: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var activityProfileImage: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        let imageWidth = imageViewProfile.frame.size.width
        let imageURL = GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: UInt(imageWidth))
        
        self.labelDisplayName.text = (user?.displayName)!
        self.imageViewProfile.layer.masksToBounds = true
        self.imageViewProfile.layer.cornerRadius = imageWidth / 2
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: imageURL!)
            DispatchQueue.main.sync {
                self.imageViewProfile.image = UIImage(data: data!)
                self.activityProfileImage.isHidden = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
