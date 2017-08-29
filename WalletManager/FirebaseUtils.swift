//
//  FirebaseUtils.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/1/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

//FirebaseNodes Constants
struct FirebaseNodes {
    struct UsersPublic {
        static let Root: String! = "usersPublic"
        static let Name: String! = "name"
        static let Email: String! = "email"
    }
    
    struct UsersPrivate {
        static let Root: String! = "usersPrivate"
        static let AccountProvider: String! = "accountProvider"
        static let Wallets: String! = "wallets"
    }
    
    struct Wallets {
        static let Root: String! = "wallets"
        static let Name: String! = "name"
        static let Description: String! = "description"
        static let CreationTime: String! = "createdAt"
        struct Members {
            static let Root: String! = "members"
            static let Group: String! = "group"
        }
    }
}

class FirebaseUtils {
    //MARK: - References Singleton
    static var databaseReference = {
        return Database.database().reference()
    }()
    
    static var storageReference = {
        return Storage.storage().reference()
    }()
    
    //MARK: - Generic fuctions
    private class func save(_ databaseReference: DatabaseReference, _ data: Any, withErrorBlock errorBlock: ((Error) -> Void)? = nil) {
        databaseReference.setValue(data, withCompletionBlock: { (error, ref) -> Void in
            if let error = error {
                if let errorBlock = errorBlock {
                    errorBlock(error)
                }
                return
            }
        })
    }
    
    //MARK: - User
    //MARK: UID
    class func getUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    //MARK: Name
    class func saveUserName(_ name: String, withErrorBlock errorBlock: ((Error) -> Void)? = nil) {
        if let uid = self.getUID() {
            self.save(self.databaseReference.child(FirebaseNodes.UsersPublic.Root).child(uid).child(FirebaseNodes.UsersPublic.Name), name, withErrorBlock: errorBlock)
        }
    }
    
    class func loadUserName(_ completion: @escaping (String?) -> Void) {
        if let uid = self.getUID() {
            self.databaseReference.child(FirebaseNodes.UsersPublic.Root).child(uid).child(FirebaseNodes.UsersPublic.Name).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                if let userName = snapshot.value as? String {
                    completion(userName)
                } else {
                    completion(nil)
                }
            })
        }
    }
    
    //MARK: Email
    class func saveUserEmail(_ email: String, withErrorBlock errorBlock: ((Error) -> Void)? = nil) {
        if let uid = self.getUID() {
            self.save(self.databaseReference.child(FirebaseNodes.UsersPublic.Root).child(uid).child(FirebaseNodes.UsersPublic.Email), email, withErrorBlock: errorBlock)
        }
    }
    
    //MARK: Account Provider
    class func saveUserAccountProvider(_ accountProvider: String, withErrorBlock errorBlock: ((Error) -> Void)? = nil) {
        if let uid = self.getUID() {
            self.save(self.databaseReference.child(FirebaseNodes.UsersPrivate.Root).child(uid).child(FirebaseNodes.UsersPrivate.AccountProvider), accountProvider, withErrorBlock: errorBlock)
        }
    }
    
    //MARK: Profile Image
    class func loadUserProfileImage(_ completion: @escaping (Data?, Error?) -> Void) {
        if let uid = self.getUID() {
            self.storageReference.child(FirebaseNodes.UsersPublic.Root).child(uid).child("profileImage").getData(maxSize: 5000000, completion: {(data, error) -> Void in
                if let error = error {
                    DebugLogger.log("Firebase - Profile image download error: \(error.localizedDescription)")
                }
                completion(data, error)                
            })
        }
    }
}
