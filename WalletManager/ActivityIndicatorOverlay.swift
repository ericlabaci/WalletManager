//
//  ActivityIndicatorOverlay.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/14/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//


class ActivityIndicatorOverlay : UIView {
    private var overlayView : UIView? = nil
    private var activityIndicator : UIActivityIndicatorView? = nil
    let label : UILabel = UILabel.init()
    
    var onHide :(() -> Void)?
    var onShow :(() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(view parentView: UIView) {
        self.overlayView = UIView.init()
        self.activityIndicator = UIActivityIndicatorView.init()
        self.activityIndicator?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        self.overlayView?.layer.backgroundColor = UIColor.init(colorLiteralRed: 100.0 / 255.0, green: 100.0 / 255.0, blue: 100.0 / 255.0, alpha: 0.85).cgColor
        self.overlayView?.layer.masksToBounds = true
        self.overlayView?.layer.cornerRadius = 5.0
        self.overlayView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator?.startAnimating()
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.text = "Label"
        self.label.textAlignment = NSTextAlignment.center
        self.label.textColor = UIColor.white
        self.label.font = UIFont.boldSystemFont(ofSize: 17.0);
        
        parentView.addSubview(self.overlayView!)
        let overlayHorizontalConstraint = NSLayoutConstraint.init(item: self.overlayView!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: parentView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0)
        let overlayVerticalConstraint = NSLayoutConstraint.init(item: self.overlayView!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: parentView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0)
        let overlayWidthConstraint = NSLayoutConstraint.init(item: self.overlayView!, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 160.0)
        let overlayHeightConstraint = NSLayoutConstraint.init(item: self.overlayView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 80.0)
        parentView.addConstraints([overlayHorizontalConstraint, overlayVerticalConstraint, overlayWidthConstraint, overlayHeightConstraint])
        
        self.overlayView?.addSubview(self.activityIndicator!)
        let activityHorizontalConstraint = NSLayoutConstraint.init(item: self.activityIndicator!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.overlayView!, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0)
        let activityVerticalConstraint = NSLayoutConstraint.init(item: self.activityIndicator!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.overlayView!, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: -12.0)
        self.overlayView?.addConstraints([activityHorizontalConstraint, activityVerticalConstraint]);
        
        overlayView!.addSubview(self.label)
        let labelLeftConstraint = NSLayoutConstraint.init(item: self.label, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: overlayView!, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 8.0)
        let labelRightConstraint = NSLayoutConstraint.init(item: self.label, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: overlayView!, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: -8.0)
        let labelVerticalConstraint = NSLayoutConstraint.init(item: self.label, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: overlayView!, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -4.0)
        let labelHeightConstraint = NSLayoutConstraint.init(item: self.label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 30.0)
        overlayView!.addConstraints([labelLeftConstraint, labelRightConstraint, labelVerticalConstraint, labelHeightConstraint])
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    func hide() {
        self.overlayView?.isHidden = true
        self.activityIndicator?.isHidden = true
        self.label.isHidden = true
        if let onHide = onHide {
            onHide()
        }
    }
    
    func show() {
        self.overlayView?.isHidden = false
        self.activityIndicator?.isHidden = false
        self.label.isHidden = false
        if let onShow = onShow {
            onShow()
        }
    }
}
