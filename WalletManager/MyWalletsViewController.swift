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
    
    //MARK: - Variables
    var walletNameArray: [(id: String, name: String, description: String, time: Int)] = []
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.walletsTableView.register(WalletTableViewCell.classForCoder(), forCellReuseIdentifier: WalletTableViewCellReuseIdentifier)
        self.walletsTableView.register(UINib(nibName: "WalletTableViewCell", bundle: nil), forCellReuseIdentifier: WalletTableViewCellReuseIdentifier)
        self.walletsTableView.separatorStyle = .none
        self.walletsTableView.delegate = self
        self.walletsTableView.dataSource = self
        
        FirebaseUtils.observeUserWalletsAdded(with: { (walletID, name, description, time) -> Void in
            self.walletNameArray.append((id: walletID, name: name, description: description, time: time))
            self.walletNameArray.sort(by: { (tuple1, tuple2) -> Bool in
                return tuple1.id < tuple2.id
            })
            if let i = self.walletNameArray.index(where: {$0.id == walletID}) {
                self.walletsTableView.insertRows(at: [IndexPath(row: i, section: 0)], with: .fade)
            }
        })
        
        FirebaseUtils.observeUserWalletsRemoved(with: { (walletID) -> Void in
            if let i = self.walletNameArray.index(where: {$0.id == walletID}) {
                self.walletNameArray.remove(at: i)
                self.walletsTableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .fade)
            }
        })
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
            cell.walletDescriptionLabel.text = self.walletNameArray[indexPath.row].description
            cell.setCreationDateLabel(creationDate: DateUtils.firebaseTimeToCreationTimeFormat(millis: self.walletNameArray[indexPath.row].time))
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "ViewWalletSegue", sender: indexPath)
    }

    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath {
            if let walletSummaryVC = segue.destination as? WalletSummaryViewController {
                walletSummaryVC.walletInfo = self.walletNameArray[indexPath.row]
            }
        }
    }
}
