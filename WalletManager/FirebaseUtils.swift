//
//  FirebaseUtils.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/1/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

//MARK: - Constants
private struct Activity {
    static let Undefined: String! = "Undefined"
    static let UserName: String! = "UserName"
    static let UserEmail: String! = "UserEmail"
    static let UserAccountProvider: String! = "UserAccountProvider"
}

private struct ActivityType {
    static let Undefined: Int! = 0
    static let Saving: Int! = 1
    static let SaveSuccess: Int! = 2
    static let SaveFail: Int! = 3
    static let Loading: Int! = 4
    static let LoadSuccess: Int! = 5
    static let LoadFail: Int! = 6
}

struct FirebaseNodes {
    struct Users {
        static let Root: String! = "users"
        static let Name: String! = "name"
        static let Email: String! = "email"
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
    private class func save(_ databaseReference: DatabaseReference, _ data: Any, _ activity: String? = Activity.Undefined, withErrorBlock errorBlock: ((Error) -> Void)? = nil) {
        self.logActivity(activity, ActivityType.Saving)
        databaseReference.setValue(data, withCompletionBlock: { (error, ref) -> Void in
            if let error = error {
                self.logActivity(activity, ActivityType.SaveFail, error.localizedDescription)
                if let errorBlock = errorBlock {
                    errorBlock(error)
                }
                return
            }
            self.logActivity(activity, ActivityType.SaveSuccess)
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
            self.save(self.databaseReference.child(FirebaseNodes.Users.Root).child(uid).child(FirebaseNodes.Users.Name), name, Activity.UserName, withErrorBlock: errorBlock)
        }
    }
    
    class func loadUserName(_ completion: @escaping (String?) -> Void) {
        if let uid = self.getUID() {
            self.logActivity(Activity.UserName, ActivityType.Loading)
            self.databaseReference.child(FirebaseNodes.Users.Root).child(uid).child(FirebaseNodes.Users.Name).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                if let userName = snapshot.value as? String {
                    self.logActivity(Activity.UserName, ActivityType.LoadSuccess)
                    completion(userName)
                } else {
                    self.logActivity(Activity.UserName, ActivityType.LoadFail)
                    completion(nil)
                }
            })
        }
    }
    
    class func observeUserName(with completion: @escaping (DataSnapshot) -> Void) {
        if let uid = self.getUID() {
            self.databaseReference.child(FirebaseNodes.Users.Root).child(uid).child(FirebaseNodes.Users.Name).observe(.value, with: completion)
        }
    }
    
    class func removeUserNameObserver() {
        if let uid = self.getUID() {
            self.databaseReference.child(FirebaseNodes.Users.Root).child(uid).child(FirebaseNodes.Users.Name).removeAllObservers()
        }
    }
    
    //MARK: Email
    class func saveUserEmail(_ email: String, withErrorBlock errorBlock: ((Error) -> Void)? = nil) {
        if let uid = self.getUID() {
            self.save(self.databaseReference.child(FirebaseNodes.Users.Root).child(uid).child(FirebaseNodes.Users.Email), email, Activity.UserEmail, withErrorBlock: errorBlock)
        }
    }
    
    //MARK: Account Provider
    class func saveUserAccountProvider(_ accountProvider: String, withErrorBlock errorBlock: ((Error) -> Void)? = nil) {
        if let uid = self.getUID() {
            self.save(self.databaseReference.child(FirebaseNodes.Users.Root).child(uid).child(FirebaseNodes.Users.AccountProvider), accountProvider, Activity.UserAccountProvider, withErrorBlock: errorBlock)
        }
    }
    
    //MARK: Profile Image
    class func loadUserProfileImage(_ completion: @escaping (Data?, Error?) -> Void) {
        if let uid = self.getUID() {
            self.storageReference.child(FirebaseNodes.Users.Root).child(uid).child("profileImage").getData(maxSize: 5000000, completion: {(data, error) -> Void in
                if let error = error {
                    DebugLogger.log("Firebase - Profile image download error: \(error.localizedDescription)")
                }
                completion(data, error)                
            })
        }
    }
    
    //MARK: Wallets
    class func observeUserWalletsAdded(with completion: @escaping (String, String, String, Int) -> Void) {
        self.databaseReference.child(FirebaseNodes.Users.Root).child(FirebaseUtils.getUID()!).child(FirebaseNodes.Users.Wallets).observe(.childAdded, with: { (snapshot) -> Void in
            //Get wallet ID
            let walletID = snapshot.key
            //Request wallet dictionary
            self.databaseReference.child(FirebaseNodes.Wallets.Root).child(walletID).observe(.value, with: { (snapshot) -> Void in
                //Check if all fields are added
                if snapshot.hasChild(FirebaseNodes.Wallets.CreationTime) {
                    let dict = snapshot.value as! [String : Any]
                    if let walletName = dict[FirebaseNodes.Wallets.Name] as? String,
                        let walletDescription = dict[FirebaseNodes.Wallets.Description] as? String,
                        let creationTime = dict[FirebaseNodes.Wallets.CreationTime] as? Int {
                        self.databaseReference.child(FirebaseNodes.Wallets.Root).child(walletID).removeAllObservers()
                        completion(walletID, walletName, walletDescription, creationTime)
                    }
                }
            })
        })
    }
    
    class func observeUserWalletsRemoved(with completion: @escaping (String) -> Void) {
        FirebaseUtils.databaseReference.child(FirebaseNodes.Users.Root).child(FirebaseUtils.getUID()!).child(FirebaseNodes.Users.Wallets).observe(.childRemoved, with: { (snapshot) -> Void in
            let walletID = snapshot.key
            FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(walletID).child(FirebaseNodes.Wallets.Name).removeAllObservers()
            completion(walletID)
        })
    }
    
    //MARK: - Debug Log
    private class func logActivity(_ activity: String?, _ type: Int?, _ description: String? = nil) {
        var activity: String! = activity
        var type: Int! = type
        
        if activity == nil {
            activity = Activity.Undefined
        }
        if type == nil {
            type = ActivityType.Undefined
        }
        
        var activityType = ""
        switch type {
        case ActivityType.Saving:
            activityType = "Saving"
            break
        
        case ActivityType.SaveSuccess:
            activityType = "Save success"
            break
        
        case ActivityType.SaveFail:
            activityType = "Save fail"
            break
            
        case ActivityType.Loading:
            activityType = "Loading"
            break
            
        case ActivityType.LoadSuccess:
            activityType = "Load success"
            break
            
        case ActivityType.LoadFail:
            activityType = "Load fail"
            break
            
        default:
            activityType = "Undefined"
            break
        }
        if let description = description {
            DebugLogger.log("FirebaseUtils [\(activity!)] - \(activityType) - \(description)")
        } else {
            DebugLogger.log("FirebaseUtils [\(activity!)] - \(activityType)")
        }
    }
}
