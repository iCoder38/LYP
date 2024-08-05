//
//  change_password.swift
//  LYV
//
//  Created by Dishant Rajput on 05/08/24.
//

import UIKit
import Alamofire

class change_password: UIViewController {
    
    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var txt_old_pass:UITextField! {
        didSet {
            txt_old_pass.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_old_pass.layer.cornerRadius = 25
            txt_old_pass.clipsToBounds = true
            txt_old_pass.placeholder = "Email"
            txt_old_pass.setLeftPaddingPoints(20)
            let placeholderText = "Old password"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_old_pass.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
            txt_old_pass.textColor = .white
        }
    }
    
    @IBOutlet weak var txt_new_password:UITextField! {
        didSet {
            txt_new_password.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_new_password.layer.cornerRadius = 25
            txt_new_password.clipsToBounds = true
            txt_new_password.placeholder = "Password"
            txt_new_password.setLeftPaddingPoints(20)
            let placeholderText = "New Password"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_new_password.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
            txt_new_password.textColor = .white
        }
    }
    
    @IBOutlet weak var txt_re_password:UITextField! {
        didSet {
            txt_re_password.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_re_password.layer.cornerRadius = 25
            txt_re_password.clipsToBounds = true
            txt_re_password.placeholder = "Password"
            txt_re_password.setLeftPaddingPoints(20)
            let placeholderText = "Confirm Password"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_re_password.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
            txt_re_password.textColor = .white
        }
    }
    
    @IBOutlet weak var btn_submit:UIButton! {
        didSet {
            btn_submit.backgroundColor = .white
            btn_submit.layer.cornerRadius = 25
            btn_submit.clipsToBounds = true
            btn_submit.setTitle("Submit", for: .normal)
            btn_submit.backgroundColor = app_purple_color
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.btn_submit.addTarget(self, action: #selector(sign_in_click_method), for: .touchUpInside)
    }
    
    @objc func sign_in_click_method() {
        self.login_wb()
        
    }
    
    @objc func login_wb() {
        
        if (self.txt_old_pass.text == "") {
            return
        }
        
        if (self.txt_new_password.text == "") {
            return
        }
        
        if (self.txt_re_password.text == "") {
            return
        }
        
        ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        var parameters:Dictionary<AnyHashable, Any>!
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            print(person)
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            
            if let token_id_is = UserDefaults.standard.string(forKey: str_save_last_api_token) {
                
                let headers: HTTPHeaders = [
                    "token":String(token_id_is),
                ]
                 
                parameters = [
                    "action"        : "changepassword",
                    "userId"        : String(myString),
                    "newPassword"   : String(self.txt_new_password.text!),
                    "oldPassword"   : String(self.txt_old_pass.text!),
                ]
                
                print("parameters-------\(String(describing: parameters))")
                
                AF.request(application_base_url, method: .post, parameters: parameters as? Parameters,headers: headers).responseJSON { [self]
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
                                self.txt_old_pass.text = ""
                                self.txt_re_password.text = ""
                                self.txt_new_password.text = ""
                            } else if strSuccess.lowercased() == "fails" {
                                ERProgressHud.sharedInstance.hide()
                                let alert = NewYorkAlertController(title: String("Alert").uppercased(), message: JSON["msg"] as? String, style: .alert)
                                let cancel = NewYorkButton(title: "dismiss", style: .cancel)
                                alert.addButtons([cancel])
                                self.present(alert, animated: true)
                            } else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.login_wb()
                                        
                                    } else if let error = error {
                                        print("Failed to refresh token: \(error.localizedDescription)")
                                        // Handle the error
                                    }
                                }

                            }
                            
                        }
                        
                    case .failure(_):
                        print("Error message:\(String(describing: response.error))")
                        ERProgressHud.sharedInstance.hide()
                        self.please_check_your_internet_connection()
                        
                        break
                    }
                }
            } else {
                TokenManager.shared.refresh_token_WB { token, error in
                    if let token = token {
                        print("Token received: \(token)")
                        
                        let str_token = "\(token)"
                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                        
                        self.login_wb()
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
    }
}
