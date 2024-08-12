//
//  welcome.swift
//  LYV
//
//  Created by Dishant Rajput on 29/07/24.
//

import UIKit

class welcome: UIViewController {

    @IBOutlet weak var btn_sign_up:UIButton! {
        didSet {
            btn_sign_up.backgroundColor = .white
            btn_sign_up.layer.cornerRadius = 25
            btn_sign_up.clipsToBounds = true
            btn_sign_up.backgroundColor = app_purple_color
        }
    }
    
    @IBOutlet weak var btn_login:UIButton! {
        didSet {
            btn_login.backgroundColor = .white
            btn_login.layer.cornerRadius = 25
            btn_login.clipsToBounds = true
            btn_login.setTitle("Login", for: .normal)
            btn_login.setTitleColor(.systemPink, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // english
        UserDefaults.standard.set("en", forKey: default_key_language)
        
        self.btn_login.addTarget(self, action: #selector(login_click_method), for: .touchUpInside)
        self.btn_sign_up.addTarget(self, action: #selector(sign_up_click_method), for: .touchUpInside)
        
        self.remember_me()
    }
    
    @objc func remember_me() {
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            print(person as Any)
            
            if person["role"] as! String == "Member" {
                let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "tab_bar_controller_id")
                self.navigationController?.pushViewController(push, animated: true)
            } else {
                debugPrint("")
                // DRIVER
                // let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "dashboard_id")
                // self.navigationController?.pushViewController(push, animated: true)
                
            }
            
        }
        
    }
    
    @objc func login_click_method() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "login_id")
        self.navigationController?.pushViewController(push, animated: true)
    }
    
    @objc func sign_up_click_method() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "registration_id")
        self.navigationController?.pushViewController(push, animated: true)
    }
    
}
