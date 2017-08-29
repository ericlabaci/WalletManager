//
//  AddMemberViewController.swift
//  WalletManager
//
//  Created by Eric Labaci on 8/29/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class AddMemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: - IBOutlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!

    //MARK: - Constraints
    @IBOutlet weak var loadingViewHeightConstraint: NSLayoutConstraint!
    var loadingViewHeightConstraintOriginal: CGFloat!
    
    //MARK: - Variables
    var memberArray: [Member] = []

    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchTextField.rightViewMode = .always
        self.searchTextField.rightView = UIImageView(image: UIImage(named: "SearchIcon")?.withRenderingMode(.alwaysTemplate))
        self.searchTextField.rightView?.tintColor = Colors.Gray
        self.searchTextField.rightView?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        self.loadingViewHeightConstraintOriginal = self.loadingViewHeightConstraint.constant
        self.loadingViewHeightConstraint.constant = 0.0
        self.loadingView.alpha = 0.0
        
        self.memberTableView.register(AddMemberTableViewCell.classForCoder(), forCellReuseIdentifier: AddMemberTableViewCellReuseIdentifier)
        self.memberTableView.register(UINib(nibName: "AddMemberTableViewCell", bundle: nil), forCellReuseIdentifier: AddMemberTableViewCellReuseIdentifier)
        self.memberTableView.delegate = self
        self.memberTableView.dataSource = self
    }
    
    //MARK: - IBActions
    @IBAction func didTapSearch(_ sender: Any) {
        if let userName = searchTextField.text, !userName.isEmpty {
            self.searchTextField.text = ""
            UIView.animate(withDuration: 0.35, animations: { () -> Void in
                self.loadingViewHeightConstraint.constant = self.loadingViewHeightConstraintOriginal
                self.loadingView.alpha = 1.0
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            })
            
            self.memberArray = []
            FirebaseUtils.databaseReference.child(FirebaseNodes.UsersPublic.Root).queryOrdered(byChild: FirebaseNodes.UsersPublic.Name).queryEqual(toValue: userName).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                if let userDict = snapshot.value as? [String : Any] {
                    for key in userDict.keys {
                        if let dict = userDict[key] as? [String : Any] {
                            if let name = dict[FirebaseNodes.UsersPublic.Name] as? String,
                                let email = dict[FirebaseNodes.UsersPublic.Email] as? String {
                                self.memberArray.append(Member(id: key, name: name, email: email))
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

    //MARK: - TableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberArray.count
    }
    
    //MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: AddMemberTableViewCellReuseIdentifier, for: indexPath) as? AddMemberTableViewCell {
            cell.nameLabel.text = self.memberArray[indexPath.row].name
            cell.emailLabel.text = self.memberArray[indexPath.row].email
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
