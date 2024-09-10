//
//  my_profile.swift
//  LYV
//
//  Created by Dishant Rajput on 05/08/24.
//

import UIKit
import SDWebImage
import Alamofire
import AVKit
import AVFoundation

class my_profile: UIViewController {

    var strUserId:String!
    
    var arr_feeds:NSMutableArray! = []
    var dictUserData: NSDictionary!
    
    @IBOutlet weak var isThisProfilePrivate:UILabel! {
        didSet {
            isThisProfilePrivate.isHidden = true
        }
    }
    
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
    
    @IBOutlet weak var lbl_name:UILabel! {
        didSet {
            lbl_name.textColor = .white
        }
    }
    @IBOutlet weak var lbl_email:UILabel!  {
        didSet {
            lbl_email.textColor = .white
        }
    }
    
    @IBOutlet weak var img_profile:UIImageView! {
        didSet {
            img_profile.layer.cornerRadius = 40
            img_profile.clipsToBounds = true
            
        }
    }
    
    @IBOutlet weak var imgBanner:UIImageView! {
        didSet {
            imgBanner.layer.cornerRadius = 2
            imgBanner.clipsToBounds = true
            
        }
    }
    
    @IBOutlet weak var btn_post:UIButton! {
        didSet {
            btn_post.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var btn_following:UIButton! {
        didSet {
            btn_following.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var btn_followers:UIButton! {
        didSet {
            btn_followers.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var btn_follow_unfollow:UIButton! {
        didSet {
            btn_follow_unfollow.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var btn_edit:UIButton! {
        didSet {
            btn_edit.backgroundColor = .clear
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = app_BG
        
        print(self.strUserId as Any)
        
        self.btn_followers.addTarget(self, action: #selector(pushToFollowersScreen), for: .touchUpInside)
        self.btn_following.addTarget(self, action: #selector(pushToFollowingScreen), for: .touchUpInside)
    }
    
    @objc func pushToFollowersScreen() {
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "follow_followers_id") as? follow_followers
        push!.strType = "A"
        self.navigationController?.pushViewController(push!, animated: true)
    }
    
    @objc func pushToFollowingScreen() {
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "follow_followers_id") as? follow_followers
        push!.strType = "B"
        self.navigationController?.pushViewController(push!, animated: true)
    }
    
    @objc func edit_c_m() {
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "edit_profile_id")
        self.navigationController?.pushViewController(push, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            print(person)
            
            if (String(self.strUserId) == "\(person["userId"]!)") {
                self.lbl_name.text = (person["fullName"] as! String)
                self.lbl_email.text = (person["email"] as! String)
                
                self.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                self.img_profile.sd_setImage(with: URL(string: (person["image"] as! String)), placeholderImage: UIImage(named: "1024"))
                
                self.imgBanner.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                self.imgBanner.sd_setImage(with: URL(string: (person["banner"] as! String)), placeholderImage: UIImage(named: "1024"))
                
                self.btn_post.setTitle("\(person["TotalPost"]!)\nPost", for: .normal)
                self.btn_post.titleLabel?.lineBreakMode = .byWordWrapping
                self.btn_post.titleLabel?.textAlignment = .center
                
                self.btn_followers.setTitle("\(person["TotalFollower"]!)\nFollowers", for: .normal)
                self.btn_followers.titleLabel?.lineBreakMode = .byWordWrapping
                self.btn_followers.titleLabel?.textAlignment = .center
                
                self.btn_following.setTitle("\(person["TotalFollowing"]!)\nFollowing", for: .normal)
                self.btn_following.titleLabel?.lineBreakMode = .byWordWrapping
                self.btn_following.titleLabel?.textAlignment = .center
                
                self.btn_follow_unfollow.layer.cornerRadius = 12
                self.btn_follow_unfollow.clipsToBounds = true
                self.btn_follow_unfollow.layer.borderColor = UIColor.black.cgColor
                self.btn_follow_unfollow.layer.borderWidth = 0.4
                self.btn_follow_unfollow.setTitle("Follow", for: .normal)
                self.btn_follow_unfollow.backgroundColor = app_purple_color
                
                self.btn_edit.addTarget(self
                                        , action: #selector(edit_c_m), for: .touchUpInside)
                self.btn_edit.isHidden = false
                
                if (person["youfollowing"] as! String) == "Yes" {
                    self.btn_follow_unfollow.setTitle("Unfollow", for: .normal)
                    self.btn_follow_unfollow.backgroundColor = app_BG
                    self.btn_follow_unfollow.layer.borderWidth = 0.5
                    self.btn_follow_unfollow.layer.borderColor = UIColor.white.cgColor
                } else {
                    self.btn_follow_unfollow.setTitle("Follow", for: .normal)
                    self.btn_follow_unfollow.backgroundColor = app_purple_color
                    self.btn_follow_unfollow.layer.borderWidth = 0.5
                    self.btn_follow_unfollow.layer.borderColor = UIColor.clear.cgColor
                }
                self.btn_follow_unfollow.isHidden = true
                self.feeds_list_WB(loader: "yes")
                self.btn_edit.setImage(UIImage(named: "edit"), for: .normal)
            } else {
                self.btn_edit.setImage(UIImage(systemName: "message.fill"), for: .normal)
                self.btn_edit.tintColor = .white
                self.btn_edit.addTarget(self, action: #selector(chatClickMethod), for: .touchUpInside)
                self.btn_edit.isHidden = false
                self.getProfileWB(loader: "yes")
            }
            
            
        }
        
        
    }
    
    @objc func chatClickMethod() {
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            print(person)
            // print(dictUserData as Any)
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            let myID = String(myString)
             
            let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BooCheckChat") as? BooCheckChat
            push!.get_chat_data = self.dictUserData! as NSDictionary
            push!.str_from_dialog = "no"
            if "\(self.dictUserData!["userId"]!)" == myID {
                // login user
                push!.str_receiver_firebase_id = "\(self.dictUserData!["userId"]!)"
                push!.str_receiver_firebase_name = "\(self.dictUserData!["fullName"]!)"
                push!.str_receiver_firebase_image = "\(self.dictUserData!["image"]!)"
            } else {
                // receiver
                push!.str_receiver_firebase_id = "\(self.dictUserData!["userId"]!)"
                push!.str_receiver_firebase_name = "\(self.dictUserData!["fullName"]!)"
                push!.str_receiver_firebase_image = "\(self.dictUserData!["image"]!)"
            }
            self.navigationController?.pushViewController(push!, animated: true)
        }
    }
    
    @objc func getProfileWB(loader:String) {
       
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
                    "action"    : "profile",
                    "userId"    : String(self.strUserId),
                    "checkID"   : String(myString),
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
                                // ERProgressHud.sharedInstance.hide()
                                
                                
                                dictUserData = (JSON["data"] as! NSDictionary)
                                
                                self.lbl_name.text = (dictUserData["fullName"] as! String)
                                self.lbl_email.text = (dictUserData["email"] as! String)
                                
                                self.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                                self.img_profile.sd_setImage(with: URL(string: (dictUserData["image"] as! String)), placeholderImage: UIImage(named: "1024"))
                                
                                self.btn_post.setTitle("\(dictUserData["TotalPost"]!)\nPost", for: .normal)
                                self.btn_post.titleLabel?.lineBreakMode = .byWordWrapping
                                self.btn_post.titleLabel?.textAlignment = .center
                                
                                self.btn_followers.setTitle("\(dictUserData["TotalFollower"]!)\nFollowers", for: .normal)
                                self.btn_followers.titleLabel?.lineBreakMode = .byWordWrapping
                                self.btn_followers.titleLabel?.textAlignment = .center
                                
                                self.btn_following.setTitle("\(dictUserData["TotalFollowing"]!)\nFollowing", for: .normal)
                                self.btn_following.titleLabel?.lineBreakMode = .byWordWrapping
                                self.btn_following.titleLabel?.textAlignment = .center
                                
                                self.btn_follow_unfollow.layer.cornerRadius = 12
                                self.btn_follow_unfollow.clipsToBounds = true
                                self.btn_follow_unfollow.layer.borderColor = UIColor.black.cgColor
                                self.btn_follow_unfollow.layer.borderWidth = 0.4
                                self.btn_follow_unfollow.setTitle("Follow", for: .normal)
                                self.btn_follow_unfollow.backgroundColor = app_purple_color
                                
                                if (dictUserData["youfollowing"] as! String) == "Yes" {
                                    self.btn_follow_unfollow.setTitle("Unfollow", for: .normal)
                                    self.btn_follow_unfollow.backgroundColor = app_BG
                                    self.btn_follow_unfollow.layer.borderWidth = 0.5
                                    self.btn_follow_unfollow.layer.borderColor = UIColor.white.cgColor
                                } else {
                                    self.btn_follow_unfollow.setTitle("Follow", for: .normal)
                                    self.btn_follow_unfollow.backgroundColor = app_purple_color
                                    self.btn_follow_unfollow.layer.borderWidth = 0.5
                                    self.btn_follow_unfollow.layer.borderColor = UIColor.clear.cgColor
                                }
                                
                                self.btn_follow_unfollow.addTarget(self, action: #selector(followUnfollowClickMethod), for: .touchUpInside)
                                
                                if ("\(self.dictUserData["who_can_show"]!)" == "") {
                                    self.othersFeedsWB(loader: "no")
                                    
                                    self.tble_view.isHidden = false
                                    self.isThisProfilePrivate.isHidden = true
                                    self.isThisProfilePrivate.text = "This profile is locked"
                                    self.isThisProfilePrivate.textColor = .white
                                    
                                    self.btn_post.isHidden = false
                                    self.btn_followers.isHidden = false
                                    self.btn_following.isHidden = false
                                    
                                } else if ("\(self.dictUserData["who_can_show"]!)" == "0") {
                                    self.othersFeedsWB(loader: "no")
                                } else if ("\(self.dictUserData["who_can_show"]!)" == "1") {
                                    if ("\(self.dictUserData["youfollowed"]!)" == "Yes"
                                        &&
                                        "\(self.dictUserData["youfollowing"]!)" == "Yes") {
                                        // yes they are friends
                                        
                                        
                                        self.tble_view.isHidden = false
                                        self.isThisProfilePrivate.isHidden = true
                                        self.isThisProfilePrivate.text = "This profile is locked"
                                        self.isThisProfilePrivate.textColor = .white
                                        
                                        self.btn_post.isHidden = false
                                        self.btn_followers.isHidden = false
                                        self.btn_following.isHidden = false
                                        
                                        self.othersFeedsWB(loader: "no")
                                    } else {
                                        // no they are not friends
                                        self.tble_view.isHidden = true
                                        self.isThisProfilePrivate.isHidden = false
                                        self.isThisProfilePrivate.text = "This profile is locked"
                                        self.isThisProfilePrivate.textColor = .white
                                        
                                        self.btn_post.isHidden = true
                                        self.btn_followers.isHidden = true
                                        self.btn_following.isHidden = true
                                        
                                        ERProgressHud.sharedInstance.hide()
                                    }
                                    
                                } else if ("\(self.dictUserData["who_can_show"]!)" == "2") {
                                    // self.othersFeedsWB(loader: "no")
                                    
                                    self.tble_view.isHidden = true
                                    self.isThisProfilePrivate.isHidden = false
                                    self.isThisProfilePrivate.text = "This profile is locked"
                                    self.isThisProfilePrivate.textColor = .white
                                    
                                    self.btn_post.isHidden = true
                                    self.btn_followers.isHidden = true
                                    self.btn_following.isHidden = true
                                    
                                    
                                    ERProgressHud.sharedInstance.hide()
                                }
                               
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.feeds_list_WB(loader: "no")
                                        
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
                        
                        self.feeds_list_WB(loader: "no")
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    @objc func followUnfollowClickMethod() {
        lightImpactVibration()
        if (dictUserData["youfollowing"] as! String) == "Yes" {
            self.follow_click_method(loader: "yes", friendId: "\(dictUserData!["userId"]!)", status: "0")
        } else {
            self.follow_click_method(loader: "yes", friendId: "\(dictUserData!["userId"]!)", status: "1")
        }
        
    }
    
    @objc func follow_click_method(loader:String,friendId:String,status:String) {
        if (loader == "yes") {
            ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        }
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
                                self.getProfileWB(loader: "no")
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
    
    @objc func othersFeedsWB(loader:String) {
       
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
                    "action"    : "postlist",
                    "userId"    : String(self.strUserId),
                     "type"      : "own",
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
                                
                                
                                
                                
                                self.arr_feeds.removeAllObjects()
                                
                                self.arr_feeds.addObjects(from: ar as! [Any])
                                print(self.arr_feeds.count)
                                
                                self.tble_view.delegate = self
                                self.tble_view.dataSource = self
                                
                                self.tble_view.reloadData()
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.feeds_list_WB(loader: "no")
                                        
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
                        
                        self.feeds_list_WB(loader: "no")
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    @objc func feeds_list_WB(loader:String) {
       
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
                    "action"    : "postlist",
                    "userId"    : String(myString),
                     "type"      : "own",
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
                                
                                
                                
                                
                                self.arr_feeds.removeAllObjects()
                                
                                self.arr_feeds.addObjects(from: ar as! [Any])
                                print(self.arr_feeds.count)
                                
                                self.tble_view.delegate = self
                                self.tble_view.dataSource = self
                                
                                self.tble_view.reloadData()
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.feeds_list_WB(loader: "no")
                                        
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
                        
                        self.feeds_list_WB(loader: "no")
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    
    @objc func like_dislike_check_before_hit(_ sender:UIButton) {
        let item = self.arr_feeds[sender.tag] as? [String:Any]
        
        var status:String!
        var postId:String!
        
        if (item!["ulike"] as! String) == "No" {
            status = "1"
        } else {
            status = "0"
        }
        
        postId = "\(item!["postId"]!)"
        
        self.like_dislike_WB(status: String(status), postId: String(postId))
        
    }
    
    
    @objc func like_dislike_WB(status:String,postId:String) {
       
        
            
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
                    "action"    : "postlike",
                    "userId"    : String(myString),
                    "postId"    : String(postId),
                    "status"    : String(status),
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
                            
                                self.feeds_list_WB(loader: "no")
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.like_dislike_WB(status: status, postId: postId)
                                        
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
                        
                        self.like_dislike_WB(status: status, postId: postId)
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    @objc func comment_click_method(_ sender:UIButton) {
        let item = self.arr_feeds[sender.tag] as? [String:Any]
        
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "comments_id") as? comments
        push!.str_post_id = "\(item!["postId"]!)"
        self.navigationController?.pushViewController(push!, animated: true)
    }
    
}


//MARK:- TABLE VIEW -
extension my_profile: UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:home_table_cell = tableView.dequeueReusableCell(withIdentifier: "home_table_cell") as! home_table_cell
        
        cell.backgroundColor = .clear
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
        
        let item = self.arr_feeds[indexPath.row] as? [String:Any]
        
        cell.lbl_username.text = (item!["userName"] as! String)
        cell.lbl_description.text = (item!["title"] as! String)
        cell.lbl_time.text = (item!["created"] as! String)
        
        if "\(item!["totalLike"]!)" == "0" {
            cell.lbl_likes.text = "\(item!["totalLike"]!) like"
        } else if "\(item!["totalLike"]!)" == "1" {
            cell.lbl_likes.text = "\(item!["totalLike"]!) like"
        } else if "\(item!["totalLike"]!)" == "" {
            cell.lbl_likes.text = "0 like"
        } else {
            cell.lbl_likes.text = "\(item!["totalLike"]!) likes"
        }
        
        
        
        if "\(item!["totalComment"]!)" == "0" {
            cell.lbl_comments.text = "\(item!["totalComment"]!) comment"
        } else if "\(item!["totalComment"]!)" == "1" {
            cell.lbl_comments.text = "\(item!["totalComment"]!) comment"
        } else if "\(item!["totalComment"]!)" == "" {
            cell.lbl_comments.text = "0 comment"
        } else {
            cell.lbl_comments.text = "\(item!["totalComment"]!) comments"
        }
        
        
        cell.btn_like.tag = indexPath.row
        if (item!["ulike"] as! String) == "No" {
            cell.btn_like.addTarget(self, action: #selector(like_dislike_check_before_hit), for: .touchUpInside)
            cell.btn_like.setImage(UIImage(systemName: "heart"), for: .normal)
            cell.btn_like.tintColor = .gray
        } else {
            cell.btn_like.addTarget(self, action: #selector(like_dislike_check_before_hit), for: .touchUpInside)
            cell.btn_like.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            cell.btn_like.tintColor = .systemPink
        }
        
        if (item!["video"] as! String) == "" {
            cell.btn_play.isHidden = true
        } else {
            cell.btn_play.tag = indexPath.row
            cell.btn_play.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
            cell.btn_play.isHidden = false
        }
        
        cell.btn_comment.tag = indexPath.row
        cell.btn_comment.addTarget(self, action: #selector(comment_click_method), for: .touchUpInside)
        
        cell.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.img_profile.sd_setImage(with: URL(string: (item!["profile_picture"] as! String)), placeholderImage: UIImage(named: "1024"))
        
        
        
        cell.img_feed_image.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.img_feed_image.sd_setImage(with: URL(string: (item!["image_1"] as! String)), placeholderImage: UIImage(named: "1024"))
        
        return cell
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "main_profile_id") as? main_profile
        self.navigationController?.pushViewController(push!, animated: true)
    }
    
    @objc func playVideo(_ sender:UIButton) {
        let item = self.arr_feeds[sender.tag] as? [String:Any]
        guard let url = URL(string: (item!["video"] as! String)) else {
            print("Invalid URL")
            return
        }
        
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

class my_profile_table_cell : UITableViewCell {
    
    @IBOutlet weak var img_profile:UIImageView! {
        didSet {
            img_profile.layer.cornerRadius = 25
            img_profile.clipsToBounds = true
            img_profile.backgroundColor = .brown
        }
    }
    
    @IBOutlet weak var lbl_username:UILabel! {
        didSet {
            lbl_username.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_time:UILabel! {
        didSet {
            lbl_time.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_tags:UILabel! {
        didSet {
            lbl_tags.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_description:UILabel! {
        didSet {
            lbl_description.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_likes:UILabel! {
        didSet {
            lbl_likes.textColor = .white
        }
    }
    @IBOutlet weak var btn_like:UIButton! {
        didSet {
             
        }
    }
    
    @IBOutlet weak var lbl_comments:UILabel!  {
        didSet {
            lbl_comments.textColor = .white
        }
    }
    
    @IBOutlet weak var img_feed_image:UIImageView! {
        didSet {
            img_feed_image.layer.cornerRadius = 16
            img_feed_image.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var btn_play:UIButton!
    
    @IBOutlet weak var btn_comment:UIButton!
}
