//
//  login.swift
//  LYV
//
//  Created by Dishant Rajput on 29/07/24.
//

import UIKit
import Alamofire

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
            txt_email.keyboardType = .emailAddress
            let placeholderText = "Email"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_email.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
            txt_email.textColor = .white
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
            txt_password.textColor = .white
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
        self.login_wb()
        
    }
    
    @objc func login_wb() {
        
        if (self.txt_email.text == "") {
            return
        }
        
        if (self.txt_password.text == "") {
            return
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        var parameters:Dictionary<AnyHashable, Any>!
        
        
        parameters = [
            "action"    : "login",
            "email"     : String(self.txt_email.text!),
            "password"  : String(self.txt_password.text!),
            "device"    : "iOS",
        ]
        
        print("parameters-------\(String(describing: parameters))")
        
        AF.request(application_base_url, method: .post, parameters: parameters as? Parameters).responseJSON {
            response in
            
            switch(response.result) {
            case .success(_):
                if let data = response.value {
                    
                    let JSON = data as! NSDictionary
                    print(JSON)
                    
                    var strSuccess : String!
                    strSuccess = JSON["status"] as? String
                    
                    if strSuccess.lowercased() == "success" {
                        ERProgressHud.sharedInstance.hide()
                        
                        var dict: Dictionary<AnyHashable, Any>
                        dict = JSON["data"] as! Dictionary<AnyHashable, Any>
                        
                        let defaults = UserDefaults.standard
                        defaults.setValue(dict, forKey: str_save_login_user_data)
                        
                        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "tab_bar_controller_id")
                        self.navigationController?.pushViewController(push, animated: true)
                        
                    } else {
                        ERProgressHud.sharedInstance.hide()
                        
                    }
                    
                    
                }
                
            case .failure(_):
                print("Error message:\(String(describing: response.error))")
                ERProgressHud.sharedInstance.hide()
                self.please_check_your_internet_connection()
                
                break
            }
        }
    }
}
