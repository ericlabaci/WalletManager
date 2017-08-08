//
//  LoginTextField.swift
//  WalletManager
//
//  Created by Eric Labaci on 7/13/17.
//  Copyright © 2017 Eric Labaci. All rights reserved.
//

import UIKit

class LoginTextField : UITextField {
    var nextField : LoginTextField!
    var identifier: String?
}

enum LoginTextFieldViewProperties: String {
    case TextFieldDelegate
    case PlaceholderText
    case Text
    case Icon
    case Secure
    case ReturnKey
    case KeyboardType
    case TextFieldNext
    case TextFieldIdentifier
}

class LoginTextFieldView: UIView {
    //MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var loginTextField: LoginTextField!
    @IBOutlet weak var iconImageView: UIImageView!
    
    //MARK: - Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("LoginTextFieldView", owner: self, options: nil)
        self.addSubview(self.contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    //MARK: - Set Properties
    func setProperties(_ dictionary: [LoginTextFieldViewProperties : Any?]) {
        for (key, value) in dictionary {
            switch key {
            case .TextFieldDelegate:
                if let textFieldDelegate = value as? UITextFieldDelegate {
                    self.setTextFieldDelegate(textFieldDelegate)
                }
                break
                
            case .PlaceholderText:
                if let placeholderText = value as? String {
                    self.setPlaceholder(placeholderText)
                }
                break
                
            case .Text:
                if let text = value as? String {
                    self.setText(text)
                }
                break
                
            case .Icon:
                if let icon = value as? UIImage {
                    self.setIcon(icon)
                }
                break
                
            case .Secure:
                if value is Bool {
                    self.setSecure(value as! Bool)
                }
                break
                
            case .ReturnKey:
                if value is UIReturnKeyType {
                    self.setReturnKey(value as! UIReturnKeyType)
                }
                break
                
            case .KeyboardType:
                if value is UIKeyboardType {
                    self.setKeyboardType(value as! UIKeyboardType)
                }
                break
                
            case .TextFieldNext:
                if let nextFieldView = value as? LoginTextFieldView {
                    self.setNextTextField(nextFieldView)
                }
                break
                
            case .TextFieldIdentifier:
                if let textFieldIdentifier = value as? String {
                    self.setTextFieldIdentifier(textFieldIdentifier)
                }
                break
            }
        }
    }
    
    //MARK: - Text Field Delegate
    func setTextFieldDelegate(_ delegate: UITextFieldDelegate?) {
        self.loginTextField.delegate = delegate
    }
    
    //MARK: - Placeholder Text
    func setPlaceholder(_ placeholder: String?) {
        self.loginTextField.placeholder = placeholder ?? ""
    }
    
    //MARK: - Text
    func setText(_ text: String?) {
        self.loginTextField.text = text ?? ""
    }
    
    func getText() -> String? {
        return self.loginTextField.text
    }
    
    //MARK: - Icon
    func setIcon(_ iconImage: UIImage?) {
//        self.iconImageView.image = iconImage
        
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0))
        imageView.image = iconImage
        imageView.contentMode = .scaleAspectFit
        self.loginTextField.rightView = imageView
        self.loginTextField.rightViewMode = .always
    }
    
    //MARK: - Secure
    func setSecure(_ secure: Bool) {
        self.loginTextField.isSecureTextEntry = secure
    }
    
    //MARK: - Return Key
    func setReturnKey(_ returnKeyType: UIReturnKeyType) {
        self.loginTextField.returnKeyType = returnKeyType
    }
    
    //MARK: - Keyboard Type
    func setKeyboardType(_ keyboardType: UIKeyboardType) {
        self.loginTextField.keyboardType = keyboardType
    }
    
    //MARK: - Next Text Field
    func setNextTextField(_ next: Any?) {
        if let loginTextFieldView = next as? LoginTextFieldView {
            self.loginTextField.nextField = loginTextFieldView.loginTextField
        } else if let loginTextField = next as? LoginTextField {
            self.loginTextField.nextField = loginTextField
        } else {
            self.loginTextField.nextField = nil
        }
    }
    
    //MARK: - Text Field Idenfitifer
    func setTextFieldIdentifier(_ identifier: String?) {
        self.loginTextField.identifier = identifier
    }
}
