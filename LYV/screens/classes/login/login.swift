//
//  login.swift
//  LYV
//
//  Created by Dishant Rajput on 29/07/24.
//

import UIKit

class login: UIViewController {

    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var txt_email:UITextField! {
        didSet {
            txt_email.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_email.layer.cornerRadius = 25
            txt_email.clipsToBounds = true
            txt_email.placeholder = "Email"
            txt_email.setLeftPaddingPoints(20)
            let placeholderText = "Email"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_email.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
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
    
    @IBOutlet weak var btn_sign_in:UIButton! {
        didSet {
            btn_sign_in.backgroundColor = .white
            btn_sign_in.layer.cornerRadius = 25
            btn_sign_in.clipsToBounds = true
            btn_sign_in.setTitle("LOGIN", for: .normal)
            btn_sign_in.backgroundColor = app_purple_color
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.btn_sign_in.addTarget(self, action: #selector(sign_in_click_method), for: .touchUpInside)
    }
    
    @objc func sign_in_click_method() {
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "home_id")
        self.navigationController?.pushViewController(push, animated: true)
    }
    
}
