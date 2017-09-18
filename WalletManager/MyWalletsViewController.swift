//
//  MyWalletsViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/24/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class MyWalletsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: - IBOutlets
    @IBOutlet weak var walletsTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    
    //MARK: - Constraints
    @IBOutlet weak var loadingViewHeightConstraint: NSLayoutConstraint!
    var loadingViewHeightConstraintOriginalValue: CGFloat!

    //MARK: - Variables
    var walletNameArray: [Wallet] = []
    var numberOfWallets: Int = 0
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.walletsTableView.register(WalletTableViewCell.classForCoder(), forCellReuseIdentifier: WalletTableViewCellReuseIdentifier)
        self.walletsTableView.register(UINib(nibName: "WalletTableViewCell", bundle: nil), forCellReuseIdentifier: WalletTableViewCellReuseIdentifier)
        self.walletsTableView.separatorStyle = .none
        self.walletsTableView.delegate = self
        self.walletsTableView.dataSource = self
        
        self.loadingViewHeightConstraintOriginalValue = self.loadingViewHeightConstraint.constant
        
        self.observeNumberOfWalletsFromUser(with: { (numberOfWallets) -> Void in
            self.numberOfWallets = numberOfWallets
            if self.numberOfWallets == 0 {
                self.hideLoadingView()
            }
        })
        
        self.observeWalletsAddedToUser(with: { (wallet) -> Void in
            self.walletNameArray.append(wallet)
            self.walletNameArray.sort(by: { (tuple1, tuple2) -> Bool in
                return tuple1.id < tuple2.id
            })
            if let i = self.walletNameArray.index(where: {$0.id == wallet.id}) {
                self.walletsTableView.insertRows(at: [IndexPath(row: i, section: 0)], with: .fade)
            }
            if self.numberOfWallets == self.walletNameArray.count {
                self.hideLoadingView()
            }
            self.observeWalletProperties(walletID: wallet.id, with: { (walletID, dict) -> Void in
                var needsReload = false
                if let i = self.walletNameArray.index(where: {$0.id == walletID}) {
                    for key in dict.keys {
                        if key == FirebaseNodes.Wallets.Name, let walletName = dict[key] as? String {
                            self.walletNameArray[i].name = walletName
                            needsReload = true
                        } else if key == FirebaseNodes.Wallets.Description, let walletDescription = dict[key] as? String {
                            self.walletNameArray[i].descr = walletDescription
                            needsReload = true
                        }
                    }
                    if needsReload {
                        self.walletsTableView.reloadAllSections(with: .fade)
                    }
                }
            })
        })
        
        self.observeWalletsRemovedFromUser(with: { (walletID) -> Void in
            if let i = self.walletNameArray.index(where: {$0.id == walletID}) {
                self.walletNameArray.remove(at: i)
                self.walletsTableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .fade)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - TableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.walletNameArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    //MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: WalletTableViewCellReuseIdentifier, for: indexPath) as? WalletTableViewCell {
            cell.walletNameLabel.text = self.walletNameArray[indexPath.row].name
            cell.walletDescriptionLabel.text = self.walletNameArray[indexPath.row].descr
            cell.setCreationDateLabel(creationDate: DateUtils.firebaseTimeToCreationTimeFormat(millis: self.walletNameArray[indexPath.row].time))
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "ViewWalletSegue", sender: indexPath)
    }

    //MARK: - Loading View
    func showLoadingView() {
        self.loadingViewHeightConstraint.constant = self.loadingViewHeightConstraintOriginalValue
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.loadingView.alpha = 1.0
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    func hideLoadingView() {
        self.loadingViewHeightConstraint.constant = 0.0
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.loadingView.alpha = 0.0
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath {
            if let walletSummaryVC = segue.destination as? WalletSummaryViewController {
                walletSummaryVC.wallet = self.walletNameArray[indexPath.row]
                self.tabBarController?.tabBar.isHidden = true
            }
        }
    }
    
    //MARK: - Firebase
    func observeWalletsAddedToUser(with completion: @escaping (Wallet) -> Void) {
        if let uid = FirebaseUtils.getUID() {
            FirebaseUtils.databaseReference.child(FirebaseNodes.UsersPrivate.Root).child(uid).child(FirebaseNodes.UsersPrivate.Wallets).observe(.childAdded, with: { (snapshot) -> Void in
                //Get wallet ID
                let walletID = snapshot.key
                //Request wallet dictionary
                var handle: UInt!
                handle = FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(walletID).observe(.value, with: { (snapshot) -> Void in
                    //Check if all fields are added
                    if snapshot.hasChild(FirebaseNodes.Wallets.CreationTime) {
                        let dict = snapshot.value as! [String : Any]
                        if let walletName = dict[FirebaseNodes.Wallets.Name] as? String,
                            let walletDescription = dict[FirebaseNodes.Wallets.Description] as? String,
                            let creationTime = dict[FirebaseNodes.Wallets.CreationTime] as? Int {
                            FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(walletID).removeObserver(withHandle: handle)
                            completion(Wallet(id: walletID, name: walletName, description: walletDescription, time: creationTime))
                        }
                    }
                })
            })
        }
    }
    
    func observeWalletsRemovedFromUser(with completion: @escaping (String) -> Void) {
        var handle: UInt!
        if let uid = FirebaseUtils.getUID() {
            handle = FirebaseUtils.databaseReference.child(FirebaseNodes.UsersPrivate.Root).child(uid).child(FirebaseNodes.UsersPrivate.Wallets).observe(.childRemoved, with: { (snapshot) -> Void in
                let walletID = snapshot.key
                FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(walletID).child(FirebaseNodes.Wallets.Name).removeObserver(withHandle: handle)
                completion(walletID)
            })
        }
    }
    
    func observeWalletProperties(walletID: String, with completion: @escaping (String, [String : Any]) -> Void) {
        FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(walletID).observe(.childChanged, with: { (snapshot) -> Void in
            if let value = snapshot.value {
                completion(walletID, [snapshot.key : value])
            }
        })
    }
    
    func observeNumberOfWalletsFromUser(with completion: @escaping (Int) -> Void) {
        FirebaseUtils.databaseReference.child(FirebaseNodes.UsersPrivate.Root).child(FirebaseUtils.getUID()!).child(FirebaseNodes.UsersPrivate.Wallets).observe(.value, with: { (snapshot) -> Void in
            completion(Int(snapshot.childrenCount))
        })
    }
}
