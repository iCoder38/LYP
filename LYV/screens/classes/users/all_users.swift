//
//  all_users.swift
//  LYV
//
//  Created by Dishant Rajput on 09/08/24.
//

import UIKit
import Alamofire
import SDWebImage

class all_users: UIViewController, UITextFieldDelegate {

    var arr_all_users:NSMutableArray! = []
    
    var page : Int! = 1
    var loadMore : Int! = 1;
    
    var str_login_user_id:String!
    
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

    @IBOutlet weak var btn_search:UIButton!
    @IBOutlet weak var txt_search:UITextField! {
        didSet {
            txt_search.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_search.layer.cornerRadius = 25
            txt_search.clipsToBounds = true
            txt_search.placeholder = "Search"
            txt_search.setLeftPaddingPoints(20)
            txt_search.textColor = .white
            let placeholderText = "Search"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_search.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = app_BG
        
       
        
        self.btn_search.addTarget(self
                                  , action: #selector(search_user_c_m), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            print(person)
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            let myID = String(myString)
            self.str_login_user_id = myID
           
        }
        self.arr_all_users.removeAllObjects()
        self.feeds_list_WB(loader:"no",pageNumber: 1)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                
        if scrollView == self.tble_view {
            let isReachingEnd = scrollView.contentOffset.y >= 0
                && scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
            if(isReachingEnd) {
                if(loadMore == 1) {
                    loadMore = 0
                    page += 1
                    print(page as Any)
                    
                    self.feeds_list_WB(loader:"no",pageNumber: page)
                    
                }
            }
        }
    }
    
    @objc func search_user_c_m() {
        self.view.endEditing(true)
        
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
                    "action"    : "userlist",
                    "userId"    : String(myString),
                    "keyword"   : String(self.txt_search.text!),
                    // "pageNo"    : pageNumber,
                   
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
                                var ar : NSArray!
                                ar = (JSON["data"] as! Array<Any>) as NSArray
                                
                                self.arr_all_users.removeAllObjects()
                                
                                self.arr_all_users.addObjects(from: ar as! [Any])
                                print(self.arr_all_users.count)
                                
                                self.tble_view.delegate = self
                                self.tble_view.dataSource = self
                                self.tble_view.reloadData()
                                // self.loadMore = 1
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.feeds_list_WB(loader:"no",pageNumber: 1)
                                        
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
                        
                        self.feeds_list_WB(loader:"no",pageNumber: 1)
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    @objc func feeds_list_WB(loader:String,pageNumber: Int) {
       
        var parameters:Dictionary<AnyHashable, Any>!
        
        if (loader == "yes") {
            ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        }
       
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            print(person)
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            
            if let token_id_is = UserDefaults.standard.string(forKey: str_save_last_api_token) {
                
                let headers: HTTPHeaders = [
                    "token":String(token_id_is),
                ]
                 
                parameters = [
                    "action"    : "userlist",
                    "userId"    : String(myString),
                    "keyword"   : "",
                    "pageNo"    : pageNumber,
                   
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
                                var ar : NSArray!
                                ar = (JSON["data"] as! Array<Any>) as NSArray
                                
                                // self.arr_all_users.removeAllObjects()
                                
                                for indexx in 0..<ar.count {
                                    let item = ar[indexx] as? [String:Any]
                                    
                                    var custom = [
                                        "created"       : "\(item!["created"]!)",
                                        "profile_picture":"\(item!["profile_picture"]!)",
                                        "ufollowing"    : "\(item!["ufollowing"]!)",
                                        "userAddress"   : "\(item!["userAddress"]!)",
                                        "userContact"   : "\(item!["userContact"]!)",
                                        "userEmail"     : "\(item!["userEmail"]!)",
                                        "userId"        : "\(item!["userId"]!)",
                                        "userName"      : "\(item!["userName"]!)",
                                    ]
                                    
//                                     self.arr_all_users.addObjects(from: ar as! [Any])
                                    self.arr_all_users.add(custom)
                               
                                }
                                
                                
                                
                                self.tble_view.delegate = self
                                self.tble_view.dataSource = self
                                self.tble_view.reloadData()
                                self.loadMore = 1
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.feeds_list_WB(loader:"no",pageNumber: 1)
                                        
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
                        
                        self.feeds_list_WB(loader:"no",pageNumber: 1)
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    @objc func get_index(_ sender:UIButton) {
        lightImpactVibration()
        
        let item = self.arr_all_users[sender.tag] as? [String:Any]
        // self.arr_all_users.removeAllObjects()
        
//        var custom = [
//            "created"       : "\(item!["created"]!)",
//            "profile_picture":"\(item!["profile_picture"]!)",
//            "ufollowing"    : "\(item!["ufollowing"]!)",
//            "userAddress"   : "\(item!["userAddress"]!)",
//            "userContact"   : "\(item!["userContact"]!)",
//            "userEmail"     : "\(item!["userEmail"]!)",
//            "userId"        : "\(item!["userId"]!)",
//            "userName"      : "\(item!["userName"]!)",
//        ]
        
        if (item!["ufollowing"] as! String) == "Yes" {
            self.arr_all_users.removeObject(at: sender.tag)
            
            let custom = [
                "created"       : "\(item!["created"]!)",
                "profile_picture":"\(item!["profile_picture"]!)",
                "ufollowing"    : "No",
                "userAddress"   : "\(item!["userAddress"]!)",
                "userContact"   : "\(item!["userContact"]!)",
                "userEmail"     : "\(item!["userEmail"]!)",
                "userId"        : "\(item!["userId"]!)",
                "userName"      : "\(item!["userName"]!)",
            ]
            
            self.arr_all_users.insert(custom, at: sender.tag)
            self.follow_click_method(loader: "yes", friendId: "\(item!["userId"]!)", status: "0")
        } else {
            self.arr_all_users.removeObject(at: sender.tag)
            
            let custom = [
                "created"       : "\(item!["created"]!)",
                "profile_picture":"\(item!["profile_picture"]!)",
                "ufollowing"    : "Yes",
                "userAddress"   : "\(item!["userAddress"]!)",
                "userContact"   : "\(item!["userContact"]!)",
                "userEmail"     : "\(item!["userEmail"]!)",
                "userId"        : "\(item!["userId"]!)",
                "userName"      : "\(item!["userName"]!)",
            ]
            self.arr_all_users.insert(custom, at: sender.tag)
            self.follow_click_method(loader: "yes", friendId: "\(item!["userId"]!)", status: "1")
        }
        
        // print(self.arr_all_users as Any)
        
        self.tble_view.reloadData()
        
        
        /*if (item!["ufollowing"] as! String) == "Yes" {
            self.follow_click_method(loader: "yes", friendId: "\(item!["userId"]!)", status: "0")
        } else {
            self.follow_click_method(loader: "yes", friendId: "\(item!["userId"]!)", status: "1")
        }*/
        
    }
    
    @objc func follow_click_method(loader:String,friendId:String,status:String) {
        
        var parameters:Dictionary<AnyHashable, Any>!
        
        /*if (loader == "yes") {
            ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        }*/
       
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            print(person)
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            
            if let token_id_is = UserDefaults.standard.string(forKey: str_save_last_api_token) {
                
                let headers: HTTPHeaders = [
                    "token":String(token_id_is),
                ]
                 
                parameters = [
                    "action"        : "follow",
                    "followerId"    : String(friendId),
                    "followingId"   : String(myString),
                    "status"        : String(status),
                   
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
//                                ERProgressHud.sharedInstance.hide()
//                                
                                // self.feeds_list_WB(loader:"no",pageNumber: 1)
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.follow_click_method(loader: "no", friendId: friendId, status: status)
                                        
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
                        
                        self.follow_click_method(loader: "no", friendId: friendId, status: status)
                        
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
extension all_users: UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_all_users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:all_users_table_cell = tableView.dequeueReusableCell(withIdentifier: "all_users_table_cell") as! all_users_table_cell
        
        cell.backgroundColor = .clear
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
        
         let item = self.arr_all_users[indexPath.row] as? [String:Any]
        
        cell.lbl_name.text = (item!["userName"] as! String)
        cell.lbl_email.text = (item!["userEmail"] as! String)
        
        cell.btn_follow.tag = indexPath.row
        
        if (item!["ufollowing"] as! String) == "Yes" {
            cell.btn_follow.setTitle("Unfollow", for: .normal)
            cell.btn_follow.backgroundColor = app_BG
            cell.btn_follow.layer.borderWidth = 0.5
            cell.btn_follow.layer.borderColor = UIColor.white.cgColor
        } else {
            cell.btn_follow.setTitle("Follow", for: .normal)
            cell.btn_follow.backgroundColor = app_purple_color
            cell.btn_follow.layer.borderWidth = 0.5
            cell.btn_follow.layer.borderColor = UIColor.clear.cgColor
        }
        
        cell.btn_follow.addTarget(self, action: #selector(get_index), for: .touchUpInside)
        
        cell.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.img_profile.sd_setImage(with: URL(string: (item!["profile_picture"] as! String)), placeholderImage: UIImage(named: "1024"))
        
        return cell
        
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.arr_all_users[indexPath.row] as? [String:Any]
        print(item as Any)
        
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "my_profile_id") as? my_profile
        push!.strUserId = "\(item!["userId"]!)"
        self.navigationController?.pushViewController(push!, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

}

class all_users_table_cell : UITableViewCell {
    
    @IBOutlet weak var img_profile:UIImageView! {
        didSet {
            img_profile.layer.cornerRadius = 12
            img_profile.clipsToBounds = true
            img_profile.backgroundColor = .white
        }
    }
    
    
    @IBOutlet weak var lbl_name:UILabel! {
        didSet {
            lbl_name.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_email:UILabel! {
        didSet {
            lbl_email.textColor = .white
        }
    }
    
    @IBOutlet weak var btn_follow:UIButton! {
        didSet {
            btn_follow.layer.cornerRadius =  15
            btn_follow.clipsToBounds = true
        }
    }
   
}
