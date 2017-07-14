//
//  ActivityIndicatorOverlay.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/14/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//


class ActivityIndicatorOverlay : UIView {
    var overlayLoginActivity : UIView? = nil
    var activityIndicator : UIActivityIndicatorView? = nil
    
    var onHide :(() -> Void)?
    var onShow :(() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(view parentView: UIView) {
        self.overlayLoginActivity = UIView.init()
        self.activityIndicator = UIActivityIndicatorView.init()
        
        self.overlayLoginActivity?.layer.backgroundColor = UIColor.init(colorLiteralRed: 100.0 / 255.0, green: 100.0 / 255.0, blue: 100.0 / 255.0, alpha: 0.85).cgColor
        self.overlayLoginActivity?.layer.masksToBounds = true
        self.overlayLoginActivity?.layer.cornerRadius = 5.0
        self.overlayLoginActivity?.translatesAutoresizingMaskIntoConstraints = false
        
        self.activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator?.startAnimating()
        
        parentView.addSubview(self.overlayLoginActivity!)
        let overlayHorizontalConstraint = NSLayoutConstraint.init(item: self.overlayLoginActivity!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: parentView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0)
        let overlayVerticalConstraint = NSLayoutConstraint.init(item: self.overlayLoginActivity!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: parentView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0)
        let overlayWidthConstraint = NSLayoutConstraint.init(item: self.overlayLoginActivity!, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 160.0)
        let overlayHeightConstraint = NSLayoutConstraint.init(item: self.overlayLoginActivity!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 80.0)
        parentView.addConstraints([overlayHorizontalConstraint, overlayVerticalConstraint, overlayWidthConstraint, overlayHeightConstraint])
        
        self.overlayLoginActivity?.addSubview(self.activityIndicator!)
        let activityHorizontalConstraint = NSLayoutConstraint.init(item: self.activityIndicator!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.overlayLoginActivity!, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0)
        let activityVerticalConstraint = NSLayoutConstraint.init(item: self.activityIndicator!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.overlayLoginActivity!, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0)
        self.overlayLoginActivity?.addConstraints([activityHorizontalConstraint, activityVerticalConstraint]);
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    func hide() {
        self.overlayLoginActivity?.isHidden = true
        self.activityIndicator?.isHidden = true
        onHide!()
    }
    
    func show() {
        self.overlayLoginActivity?.isHidden = false
        self.activityIndicator?.isHidden = false
        onShow!()
    }
}
