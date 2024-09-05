//
//  main_profile.swift
//  LYV
//
//  Created by Dishant Rajput on 05/08/24.
//

import UIKit
import Alamofire

class main_profile: UIViewController {

    var arr_profile = ["My Profile","Change password","My order","Wishlist","Notification setting","Who can view my profile","Help","Account delete","Logout"]
    var arr_profile_name = ["person","lock","newspaper","heart.fill","heart.fill","heart.fill","heart.fill","heart.fill","lock"]
    
    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.tintColor = .white
            btn_back.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var tble_view:UITableView! {
        didSet {
            tble_view.backgroundColor = .clear
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tble_view.delegate = self
        self.tble_view.dataSource = self
        self.tble_view.reloadData()
        
        self.view.backgroundColor = app_BG
    }
    
    @objc func updateWhoCanViewMyProfileWB(key:String,value:String) {
        
        var parameters:Dictionary<AnyHashable, Any>!
        
        ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            print(person)
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            
            if let token_id_is = UserDefaults.standard.string(forKey: str_save_last_api_token) {
                
                let headers: HTTPHeaders = [
                    "token":String(token_id_is),
                ]
                
                parameters = [
                    "action"    : "editProfile",
                    "userId"    : String(myString),
                    key   : value,
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
                                
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.updateWhoCanViewMyProfileWB(key: key, value: value)
                                        
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
                        
                        self.updateWhoCanViewMyProfileWB(key: key, value: value)
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
}

//MARK:- TABLE VIEW -
extension main_profile: UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_profile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:main_profile_table_cell = tableView.dequeueReusableCell(withIdentifier: "main_profile_table_cell") as! main_profile_table_cell
        
        cell.backgroundColor = .clear
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
        
        cell.lbl_title.text = self.arr_profile[indexPath.row]
        cell.img_profile.image = UIImage(systemName: self.arr_profile_name[indexPath.row])
        cell.img_profile.tintColor = .white
        
        cell.accessoryType = .disclosureIndicator
        cell.tintColor = .white
        
        return cell
        
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.row == 0) {
            
            if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
                let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "my_profile_id") as? my_profile
                push!.strUserId = "\(person["userId"]!)"
                self.navigationController?.pushViewController(push!, animated: true)
            }
            
        } else  if (indexPath.row == 1) {
            
            let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "change_password_id") as? change_password
            self.navigationController?.pushViewController(push!, animated: true)
            
        } else  if (indexPath.row == 2) {
            
            let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "my_orders_id") as? my_orders
            self.navigationController?.pushViewController(push!, animated: true)
            
        } else if (indexPath.row == 4) {
            
            self.openAppSetting()
        } else if (indexPath.row == 5) {
            
            self.showSheetOfWhoCanViewMyProfile()
        } else if (indexPath.row == 6) {
            
            let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "help_id") as? help
            self.navigationController?.pushViewController(push!, animated: true)
            
        }
        
    }
    
    @objc func showSheetOfWhoCanViewMyProfile() {
        let alert = UIAlertController(title: "Who can view my profile", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "All", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
            self.updateWhoCanViewMyProfileWB(key: "who_can_show", value: "0")
        }))
        alert.addAction(UIAlertAction(title: "Friends only", style: .default , handler:{ (UIAlertAction)in
            print("User click Edit button")
            self.updateWhoCanViewMyProfileWB(key: "who_can_show", value: "1")
        }))
        alert.addAction(UIAlertAction(title: "Only me", style: .default , handler:{ (UIAlertAction)in
            print("User click Delete button")
            self.updateWhoCanViewMyProfileWB(key: "who_can_show", value: "2")
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    @objc func openAppSetting() {
        if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettingsURL) {
                UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func logoutpopup() {
        let alert = NewYorkAlertController(title: String("Logout").uppercased(), message: String("Are you sure your want to logout"), style: .alert)
        let yes = NewYorkButton(title: "Yes, logout", style: .default) {
            _ in
            let defaults = UserDefaults.standard
            defaults.setValue("", forKey: str_save_login_user_data)
            defaults.setValue(nil, forKey: str_save_login_user_data)
            
            let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "welcome_id")
            self.navigationController?.pushViewController(push, animated: true)
            
        }
        let no = NewYorkButton(title: "dismiss", style: .cancel) {
            _ in
            
        }
        alert.addButtons([yes,no])
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

}

class main_profile_table_cell : UITableViewCell {
    
    @IBOutlet weak var img_profile:UIImageView! {
        didSet {
            /*img_profile.layer.cornerRadius = 25
            img_profile.clipsToBounds = true*/
            img_profile.backgroundColor = .clear
        }
    }
    
    
    @IBOutlet weak var lbl_title:UILabel! {
        didSet {
            lbl_title.textColor = .white
        }
    }
    
     
   
}
