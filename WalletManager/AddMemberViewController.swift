//
//  AddMemberViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/29/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class AddMemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    //MARK: - IBOutlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var addMembersButton: UIButton!

    //MARK: - Constraints
    @IBOutlet weak var loadingViewHeightConstraint: NSLayoutConstraint!
    var loadingViewHeightConstraintOriginal: CGFloat!
    
    //MARK: - Variables
    var wallet: Wallet!
    var memberArray: [(member: Member, isSelected: Bool)] = [] {
        didSet(oldValue) {
            self.changeAddMemberButtonEnabled()
        }
    }

    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchTextField.rightViewMode = .always
        self.searchTextField.rightView = UIImageView(image: UIImage(named: "SearchIcon")?.withRenderingMode(.alwaysTemplate))
        self.searchTextField.rightView?.tintColor = Colors.Gray
        self.searchTextField.rightView?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        self.searchTextField.returnKeyType = .search
        self.searchTextField.delegate = self
        
        self.changeAddMemberButtonEnabled()
        
        self.loadingViewHeightConstraintOriginal = self.loadingViewHeightConstraint.constant
        self.loadingViewHeightConstraint.constant = 0.0
        self.loadingView.alpha = 0.0
        
        self.memberTableView.register(AddMemberTableViewCell.classForCoder(), forCellReuseIdentifier: AddMemberTableViewCellReuseIdentifier)
        self.memberTableView.register(UINib(nibName: "AddMemberTableViewCell", bundle: nil), forCellReuseIdentifier: AddMemberTableViewCellReuseIdentifier)
        self.memberTableView.delegate = self
        self.memberTableView.dataSource = self
    }
    
    //MARK: - IBActions
    @IBAction func didTapAddMembers(_ sender: Any) {
        var dict: [String : Any] = [:]
        for (member, isSelected) in self.memberArray {
            if isSelected {
                dict[member.id] = [FirebaseNodes.Wallets.Members.Group : "Member"]
            }
        }
        FirebaseUtils.databaseReference.child(FirebaseNodes.Wallets.Root).child(self.wallet.id).child(FirebaseNodes.Wallets.Members.Root).updateChildValues(dict, withCompletionBlock: { (error, reference) -> Void in
            if let error = error {
                DebugLogger.log("Error adding users: \(error.localizedDescription)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    func search(userName: String) {
        var userName = userName
        if !userName.isEmpty {
            self.searchTextField.text = ""
            userName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
            userName = userName.lowercased()
            UIView.animate(withDuration: 0.35, animations: { () -> Void in
                self.loadingViewHeightConstraint.constant = self.loadingViewHeightConstraintOriginal
                self.loadingView.alpha = 1.0
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            })
            
            self.memberArray = []
            FirebaseUtils.databaseReference.child(FirebaseNodes.UsersPublic.Root).queryStarting(atValue: userName).queryEnding(atValue: "\(userName)\u{f8ff}").queryOrdered(byChild: FirebaseNodes.UsersPublic.SearchName).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                if let userDict = snapshot.value as? [String : Any] {
                    for key in userDict.keys {
                        if let uid = FirebaseUtils.getUID() {
                            if uid == key {
                                continue
                            }
                        }
                        if let dict = userDict[key] as? [String : Any] {
                            if let name = dict[FirebaseNodes.UsersPublic.Name] as? String,
                                let email = dict[FirebaseNodes.UsersPublic.Email] as? String {
                                self.memberArray.append((member: Member(id: key, name: name, email: email), isSelected: false))
                            }
                        }
                    }
                }
                self.memberTableView.reloadAllSections(with: .fade)
                UIView.animate(withDuration: 0.35, animations: { () -> Void in
                    self.loadingViewHeightConstraint.constant = 0.0
                    self.loadingView.alpha = 0.0
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                })
            })
        }
    }

    //MARK: - TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let userName = textField.text {
            self.search(userName: userName)
        }
        
        return true
    }
    
    //MARK: - TableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    //MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: AddMemberTableViewCellReuseIdentifier, for: indexPath) as? AddMemberTableViewCell {
            cell.nameLabel.text = self.memberArray[indexPath.row].member.name
            cell.emailLabel.text = self.memberArray[indexPath.row].member.email
            cell.selectedImageView.alpha = self.memberArray[indexPath.row].isSelected ? 1.0 : 0.0
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.memberArray[indexPath.row].isSelected = !self.memberArray[indexPath.row].isSelected
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    //MARK: - Helpers
    func changeAddMemberButtonEnabled() {
        let selectedCount = self.memberArray.reduce(0) { $0 + (($1.isSelected) ? 1 : 0) }
        let backgroundColor = selectedCount > 0 ? UIColor(red: 159 / 255.0, green: 188 / 255.0, blue: 255 / 255.0, alpha: 1.0) : Colors.Gray
        self.addMembersButton.isEnabled = selectedCount > 0
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.addMembersButton.backgroundColor = backgroundColor
        })
    }
}
