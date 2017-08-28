//
//  Extensions.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/14/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

extension Notification.Name {
    static let GoogleLoginSuccess = Notification.Name("GoogleLoginSuccess")
    static let GoogleLoginFail = Notification.Name("GoogleLoginFail")
    static let GoogleLogoutSuccess = Notification.Name("GoogleLogoutSuccess")
    static let GoogleLogoutFail = Notification.Name("GoogleLogoutFail")
}

extension UIImageView {
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.85
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
}

extension UITableView {
    func reloadAllSections(with reloadRowAnimation: UITableViewRowAnimation) {
        let range = NSMakeRange(0, self.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.reloadSections(sections as IndexSet, with: reloadRowAnimation)
    }
}
