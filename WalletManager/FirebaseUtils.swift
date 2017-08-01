//
//  FirebaseUtils.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/1/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

class FirebaseUtils {
    private static var databaseReference = {
        return Database.database().reference()
    }()
    
    class func saveUserName(_ name: String) {
        if let uid = Auth.auth().currentUser?.uid {
            self.databaseReference.child("users").child(uid).child("name").setValue(name)
        }
    }
    
    class func saveUserEmail(_ email: String) {
        if let uid = Auth.auth().currentUser?.uid {
            self.databaseReference.child("users").child(uid).child("email").setValue(email)
        }
    }
    
    class func saveUserAccountProvider(_ accountProvider: String) {
        if let uid = Auth.auth().currentUser?.uid {
            self.databaseReference.child("users").child(uid).child("accountProvider").setValue(accountProvider)
        }
    }
}
