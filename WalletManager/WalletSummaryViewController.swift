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
    @IBOutlet weak var memberTableView: UITableView!
    
    //MARK: - Variables
    var walletInfo: (id: String, name: String, description: String, time: Int)!
    var memberArray: [Member] = []
    
    let sortMembersClosure = { (member1: Member, member2: Member) -> Bool in
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

        if self.walletInfo == nil {
            self.navigationController?.popViewController(animated: true)
        }
        
        self.walletNameLabel.text = self.walletInfo?.name
        self.walletDescriptionLabel.text = self.walletInfo?.description
        
        self.segmentedControl.layer.borderColor = UIColor.black.cgColor
        self.segmentedControl.layer.cornerRadius = 0.0
        self.segmentedControl.layer.borderWidth = 1.5
        
        self.summaryView.isHidden = false
        
        self.memberTableView.separatorStyle = .none
        self.memberTableView.delegate = self
        self.memberTableView.dataSource = self
        self.memberTableView.isHidden = true
        self.memberTableView.register(MemberTableViewCell.classForCoder(), forCellReuseIdentifier: MemberTableViewCellReuseIdentifier)
        self.memberTableView.register(UINib(nibName: "MemberTableViewCell", bundle: nil), forCellReuseIdentifier: MemberTableViewCellReuseIdentifier)

        //Fetch members (new and existing ones)
        FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(self.walletInfo.id).child(FirebaseNodes.Wallets.Members.Root).observe(.childAdded, with: { (snapshot) -> Void in
            let userID = snapshot.key
            if snapshot.hasChild(FirebaseNodes.Wallets.Members.Group) {
                let dict = snapshot.value as! [String : Any]
                if let userGroup = dict[FirebaseNodes.Wallets.Members.Group] as? String {
                    FirebaseUtils.databaseReference.child(FirebaseNodes.Users.Root).child(userID).child(FirebaseNodes.Users.Name).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                        if let userName = snapshot.value as? String {
                            self.memberArray.append(Member(id: userID, name: userName, group: userGroup))
                            self.memberArray.sort(by: self.sortMembersClosure)
                            self.memberTableView.reloadData()
                        }
                        //Fetch member property changes
                        FirebaseUtils.databaseReference.child(FirebaseNodes.Users.Root).child(userID).observe(.childChanged, with: { (snapshot) -> Void in
                            //Name changed
                            if snapshot.key == FirebaseNodes.Users.Name {
                                if let userName = snapshot.value as? String {
                                    if let i = self.memberArray.index(where: {$0.id == userID}) {
                                        self.memberArray[i].name = userName
                                        self.memberArray.sort(by: self.sortMembersClosure)
                                        self.memberTableView.reloadAllSections(with: .fade)
                                    }
                                }
                            }
                        })
                    })
                }
            }
        })
        
        //Fetch group changes
        FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(self.walletInfo.id).child(FirebaseNodes.Wallets.Members.Root).observe(.childChanged, with: { (snapshot) -> Void in
            let userID = snapshot.key
            if snapshot.hasChild(FirebaseNodes.Wallets.Members.Group) {
                let dict = snapshot.value as! [String : Any]
                if let userGroup = dict[FirebaseNodes.Wallets.Members.Group] as? String {
                    //Get member index (i)
                    if let i = self.memberArray.index(where: {$0.id == userID}) {
                        self.memberArray[i].group = userGroup
                        self.memberArray.sort(by: self.sortMembersClosure)
                        self.memberTableView.reloadAllSections(with: .fade)
                    }
                }
            }
        })
        
        //Fetch member removal
        FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(self.walletInfo.id).child(FirebaseNodes.Wallets.Members.Root).observe(.childRemoved, with: { (snapshot) -> Void in
            let userID = snapshot.key
            if let i = self.memberArray.index(where: {$0.id == userID}) {
                self.memberArray.remove(at: i)
                self.memberTableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .fade)
            }
            FirebaseUtils.databaseReference.child(FirebaseNodes.Users.Root).child(userID).removeAllObservers()
        })
        
        //Fetch own removal
        FirebaseUtils.databaseReference.child(FirebaseNodes.Users.Root).child(FirebaseUtils.getUID()!).child(FirebaseNodes.Users.Wallets).child(self.walletInfo.id).observe(.value, with: { (snapshot) -> Void in
            if !(snapshot.value is Bool) {
                FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(self.walletInfo.id).child(FirebaseNodes.Wallets.Members.Root).removeAllObservers()
                let alertController = UIAlertController(title: "Sorry", message: "You were removed from this wallet. :(", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    //MARK: - IBActions
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        if let segmentedControl = sender as? UISegmentedControl {
            let index = segmentedControl.selectedSegmentIndex
            switch index {
            case 0:
                self.summaryView.isHidden = false
                self.memberTableView.isHidden = true
            case 1:
                self.summaryView.isHidden = true
                self.memberTableView.isHidden = false
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
}

private extension UITableView {
    func reloadAllSections(with reloadRowAnimation: UITableViewRowAnimation) {
        let range = NSMakeRange(0, self.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.reloadSections(sections as IndexSet, with: reloadRowAnimation)
    }
}
