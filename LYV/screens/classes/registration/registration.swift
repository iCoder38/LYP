//
//  registration.swift
//  LYV
//
//  Created by Dishant Rajput on 29/07/24.
//

import UIKit

class registration: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var txt_username:UITextField! {
        didSet {
            txt_username.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_username.layer.cornerRadius = 25
            txt_username.clipsToBounds = true
            txt_username.placeholder = "Username"
            txt_username.setLeftPaddingPoints(20)
            let placeholderText = "Username"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_username.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        }
    }
    
    @IBOutlet weak var txt_email:UITextField! {
        didSet {
            txt_email.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_email.layer.cornerRadius = 25
            txt_email.clipsToBounds = true
            txt_email.placeholder = "Email"
            txt_email.setLeftPaddingPoints(20)
            txt_email.keyboardType = .emailAddress
            let placeholderText = "Email"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_email.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        }
    }
    
    @IBOutlet weak var txt_phone:UITextField! {
        didSet {
            txt_phone.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_phone.layer.cornerRadius = 25
            txt_phone.clipsToBounds = true
            txt_phone.placeholder = "Phone"
            txt_phone.setLeftPaddingPoints(20)
            txt_phone.keyboardType = .phonePad
            let placeholderText = "Phone"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_phone.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        }
    }
    
    @IBOutlet weak var txt_dob:UITextField! {
        didSet {
            txt_dob.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_dob.layer.cornerRadius = 25
            txt_dob.clipsToBounds = true
            txt_dob.placeholder = "Date of birth"
            txt_dob.setLeftPaddingPoints(20)
            let placeholderText = "Date of birth"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_dob.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        }
    }
    
    @IBOutlet weak var txt_password:UITextField! {
        didSet {
            txt_password.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_password.layer.cornerRadius = 25
            txt_password.clipsToBounds = true
            txt_password.placeholder = "Password"
            txt_password.setLeftPaddingPoints(20)
            let placeholderText = "Password"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_password.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        }
    }
    
    @IBOutlet weak var btn_sign_up:UIButton! {
        didSet {
            btn_sign_up.backgroundColor = .white
            btn_sign_up.layer.cornerRadius = 25
            btn_sign_up.clipsToBounds = true
            btn_sign_up.setTitle("SIGN UP", for: .normal)
            btn_sign_up.backgroundColor = app_purple_color
        }
    }
    
    @IBOutlet weak var btn_dob:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
}
