//
//  registration.swift
//  LYV
//
//  Created by Dishant Rajput on 29/07/24.
//

import UIKit
import Alamofire

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
            txt_username.textColor = .white
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
            txt_email.textColor = .white
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
            txt_phone.textColor = .white
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
            txt_dob.textColor = .white
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
            txt_password.textColor = .white
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
        
        self.btn_dob.addTarget(self, action: #selector(date_click_start), for: .touchUpInside)
        self.btn_sign_up.addTarget(self, action: #selector(sign_up_click_method), for: .touchUpInside)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    @objc func date_click_start() {
         
        RPicker.selectDate(title: "Select date", cancelText: "Cancel", datePickerMode: .date, maxDate: Date.now, didSelectDate: { (selectedDate) in
             
            self.txt_dob.text = selectedDate.dateString("yyyy-MM-dd")
            
        })
    }
    
    @objc func sign_up_click_method() {
        self.registration_WB()
        
    }
    
    @objc func registration_WB() {
        
        if (self.txt_email.text == "") {
            return
        }
        
        if (self.txt_password.text == "") {
            return
        }
        
        if (self.txt_username.text == "") {
            return
        }
        
        if (self.txt_dob.text == "") {
            return
        }
        
        if (self.txt_phone.text == "") {
            return
        }
        
        ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        var parameters:Dictionary<AnyHashable, Any>!
        
        
        parameters = [
            "action"    : "registration",
            "email"     : String(self.txt_email.text!),
            "password"  : String(self.txt_password.text!),
            "fullName"  : String(self.txt_username.text!),
            "dob"       : String(self.txt_dob.text!),
            "contactNumber"  : String(self.txt_phone.text!),
            "device"    : "iOS",
            "deviceToken"    : "iOS",
            "role"      : "Member",
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
