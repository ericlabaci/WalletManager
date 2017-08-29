//
//  NewWalletViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/28/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class NewWalletViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!

    //MARK: - Variables

    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - IBActions
    @IBAction func createWallet(_ sender: Any) {
        if let walletName = self.nameTextField.text,
            let walletDescription = self.descriptionTextField.text,
            !walletName.isEmpty {
            let walletReference = FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).childByAutoId()
            walletReference.child(FirebaseNodes.Wallets.Members.Root).child(FirebaseUtils.getUID()!).child(FirebaseNodes.Wallets.Members.Group).setValue("Owner", withCompletionBlock: { (error, reference) -> Void in
                if let error = error {
                    DebugLogger.log("Error creating wallet (adding owner): \(error.localizedDescription)")
                } else {
                    let dict: [String : Any] = [FirebaseNodes.Wallets.Name : walletName,
                                                FirebaseNodes.Wallets.Description : walletDescription]
                    walletReference.updateChildValues(dict, withCompletionBlock: {(error, reference) -> Void in
                        if let error = error {
                            DebugLogger.log("Error creating wallet (setting properties): \(error.localizedDescription)")
                        } else {
                            var handle: UInt!
                            handle = walletReference.observe(.childAdded, with: { (snapshot) -> Void in
                                if snapshot.key == FirebaseNodes.Wallets.CreationTime {
                                    walletReference.child(FirebaseNodes.Wallets.Root).removeObserver(withHandle: handle)
                                    self.navigationController?.popViewController(animated: true)
                                }
                            })
                        }
                    })
                }
            })
        }
    }
}
