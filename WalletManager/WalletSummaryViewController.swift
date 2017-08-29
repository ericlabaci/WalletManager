//
//  WalletSummaryViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/24/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class WalletSummaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: - IBOutlets
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletDescriptionLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var memberView: UIView!
    @IBOutlet weak var memberTableView: UITableView!
    
    //MARK: - Variables
    var wallet: Wallet!
    var memberArray: [WalletMember] = []
    
    let sortMembersClosure = { (member1: WalletMember, member2: WalletMember) -> Bool in
        let group1 = member1.group
        let group2 = member2.group
        if group1 == group2 {
            return member1.name < member2.name
        }
        if group1 == "Owner" {
            return true
        } else if group2 == "Owner" {
            return false
        } else if group1 == "Member" {
            return true
        } else if group2 == "Member" {
            return false
        } else if group1 == "Guest" {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.wallet == nil {
            self.navigationController?.popViewController(animated: true)
        }
        
        self.walletNameLabel.text = self.wallet?.name
        self.walletDescriptionLabel.text = self.wallet?.descr
        
        self.segmentedControl.layer.borderColor = UIColor.black.cgColor
        self.segmentedControl.layer.cornerRadius = 0.0
        self.segmentedControl.layer.borderWidth = 1.5
        
        self.summaryView.isHidden = false
        
        self.memberView.isHidden = true
        self.memberTableView.register(MemberTableViewCell.classForCoder(), forCellReuseIdentifier: MemberTableViewCellReuseIdentifier)
        self.memberTableView.register(UINib(nibName: "MemberTableViewCell", bundle: nil), forCellReuseIdentifier: MemberTableViewCellReuseIdentifier)
        self.memberTableView.separatorStyle = .none
        self.memberTableView.delegate = self
        self.memberTableView.dataSource = self

        //Fetch members (new and existing ones)
        self.fetchWalletMembers(with: { (member) -> Void in
            self.memberArray.append(WalletMember(id: member.id, name: member.name, group: member.group))
            self.memberArray.sort(by: self.sortMembersClosure)
            self.memberTableView.reloadData()
            
            //Fetch member property changes
            self.observeWalletMemberName(userID: member.id, completion: { (name) -> Void in
                if let i = self.memberArray.index(where: {$0.id == member.id}) {
                    self.memberArray[i].name = name
                    self.memberArray.sort(by: self.sortMembersClosure)
                    self.memberTableView.reloadAllSections(with: .fade)
                }
            })
        })
        
        //Fetch member group changes
        self.observeWalletMemberGroupChanges(with: { (userID, userGroup) -> Void in
            //Get member index (i)
            if let i = self.memberArray.index(where: {$0.id == userID}) {
                self.memberArray[i].group = userGroup
                self.memberArray.sort(by: self.sortMembersClosure)
                self.memberTableView.reloadAllSections(with: .fade)
            }
        })
        
        //Fetch member removal
        self.observeWalletUserRemoved(walletID: self.wallet.id, completion: { (userID) -> Void in
            if let i = self.memberArray.index(where: {$0.id == userID}) {
                self.memberArray.remove(at: i)
                self.memberTableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .fade)
            }
            self.removeAllWalletMemberPropertiesObservers(userID: userID)
        })
        
        //Fetch own removal
        self.observeOwnRemovalFromWallet(walletID: self.wallet.id, completion: { () -> Void in
            let alertController = UIAlertController(title: "Sorry", message: "You were removed from this wallet. :(", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                self.navigationController?.popViewController(animated: true)
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    //MARK: - IBActions
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        if let segmentedControl = sender as? UISegmentedControl {
            let index = segmentedControl.selectedSegmentIndex
            switch index {
            case 0:
                self.summaryView.isHidden = false
                self.memberView.isHidden = true
            case 1:
                self.summaryView.isHidden = true
                self.memberView.isHidden = false
            default:
                break
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberArray.count
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MemberTableViewCellReuseIdentifier, for: indexPath) as? MemberTableViewCell {
            cell.memberNameLabel.text = self.memberArray[indexPath.row].name
            cell.group = self.memberArray[indexPath.row].group
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Firebase
    func fetchWalletMembers(with completion: @escaping (WalletMember) -> Void) {
        FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(self.wallet.id).child(FirebaseNodes.Wallets.Members.Root).observe(.childAdded, with: { (snapshot) -> Void in
            let userID = snapshot.key
            if snapshot.hasChild(FirebaseNodes.Wallets.Members.Group) {
                let dict = snapshot.value as! [String : Any]
                if let userGroup = dict[FirebaseNodes.Wallets.Members.Group] as? String {
                    FirebaseUtils.databaseReference.child(FirebaseNodes.UsersPublic.Root).child(userID).child(FirebaseNodes.UsersPublic.Name).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                        if let userName = snapshot.value as? String {
                            completion(WalletMember(id: userID, name: userName, group: userGroup))
                        }
                    })
                }
            }
        })
    }
    
    func observeWalletMemberName(userID: String, completion: @escaping (String) -> Void) {
        FirebaseUtils.databaseReference.child(FirebaseNodes.UsersPublic.Root).child(userID).observe(.childChanged, with: { (snapshot) -> Void in
            //Name changed
            if snapshot.key == FirebaseNodes.UsersPublic.Name {
                if let userName = snapshot.value as? String {
                    completion(userName)
                }
            }
        })
    }
    
    func observeWalletMemberGroupChanges(with completion: @escaping (String, String) -> Void) {
        FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(self.wallet.id).child(FirebaseNodes.Wallets.Members.Root).observe(.childChanged, with: { (snapshot) -> Void in
            let userID = snapshot.key
            if snapshot.hasChild(FirebaseNodes.Wallets.Members.Group) {
                let dict = snapshot.value as! [String : Any]
                if let userGroup = dict[FirebaseNodes.Wallets.Members.Group] as? String {
                    completion(userID, userGroup)
                }
            }
        })
    }
    
    func observeWalletUserRemoved(walletID: String, completion: @escaping (String) -> Void) {
        FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(walletID).child(FirebaseNodes.Wallets.Members.Root).observe(.childRemoved, with: { (snapshot) -> Void in
            let userID = snapshot.key
            completion(userID)
        })
    }
    
    func removeAllWalletMemberPropertiesObservers(userID: String) {
        FirebaseUtils.databaseReference.child(FirebaseNodes.UsersPublic.Root).child(userID).removeAllObservers()
    }
    
    func observeOwnRemovalFromWallet(walletID: String, completion: @escaping () -> Void) {
        if let uid = FirebaseUtils.getUID() {
            FirebaseUtils.databaseReference.child(FirebaseNodes.UsersPrivate.Root).child(uid).child(FirebaseNodes.UsersPrivate.Wallets).child(walletID).observe(.value, with: { (snapshot) -> Void in
                print(snapshot)
                if !(snapshot.value is Bool) {
                    FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(walletID).child(FirebaseNodes.Wallets.Members.Root).removeAllObservers()
                    completion()
                }
            })
        }
    }
}
