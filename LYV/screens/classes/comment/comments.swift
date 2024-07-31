//
//  comments.swift
//  LYV
//
//  Created by Dishant Rajput on 31/07/24.
//

import UIKit
import Alamofire
import SDWebImage

class comments: UIViewController, UITextFieldDelegate {

    var str_post_id:String!
    var arr_comment:NSMutableArray! = []
    
    @IBOutlet weak var view_text:UIView! {
        didSet {
            view_text.backgroundColor = .clear
            
        }
    }
    
    @IBOutlet weak var txt_comment:UITextField! {
        didSet {
            txt_comment.textColor = .white
            txt_comment.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_comment.layer.cornerRadius = 25
            txt_comment.clipsToBounds = true
            txt_comment.placeholder = "Write comment"
            txt_comment.setLeftPaddingPoints(20)
            let placeholderText = "Write comment"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_comment.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        }
    }
    
    @IBOutlet weak var btn_Send:UIButton!
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
    
    var viewTextBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = app_BG
        self.txt_comment.delegate = self
        
        self.btn_Send.addTarget(self, action: #selector(post_comment_WB), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.comment_list_WB(loader: "yes")
    }
    
 
    
    @objc func comment_list_WB(loader:String) {
       
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
                    "action"    : "commentlist",
                    "userId"    : String(myString),
                    "postId"    : String(str_post_id),
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
                                
                                self.arr_comment.removeAllObjects()
                                
                                self.arr_comment.addObjects(from: ar as! [Any])
                                print(self.arr_comment.count)
                                
//                                setupConstraints()
//                                // Register for keyboard notifications
//                                        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//                                        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
                                
                                
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
                                        
                                        self.comment_list_WB(loader: "no")
                                        
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
                        
                        self.comment_list_WB(loader: "no")
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    
    
    
    @objc func post_comment_WB( ) {
       
        var parameters:Dictionary<AnyHashable, Any>!
        
         
            ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        
            
        if self.txt_comment.text! == "" {
            
            return
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
                    "action"    : "postcomment",
                    "userId"    : String(myString),
                    "postId"    : String(str_post_id),
                    "comment"   : String(self.txt_comment.text!)
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
                                self.comment_list_WB(loader: "no")
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.post_comment_WB()
                                        
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
                        
                        self.post_comment_WB()
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    
    
    deinit {
        // Unregister from keyboard notifications
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -keyboardHeight
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    func setupConstraints() {
            view_text.translatesAutoresizingMaskIntoConstraints = false
        self.txt_comment.translatesAutoresizingMaskIntoConstraints = false
            
            viewTextBottomConstraint = view_text.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            
            NSLayoutConstraint.activate([
                viewTextBottomConstraint,
                view_text.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                view_text.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                view_text.heightAnchor.constraint(equalToConstant: 60),
                
                txt_comment.leadingAnchor.constraint(equalTo: view_text.leadingAnchor, constant: 8),
                txt_comment.trailingAnchor.constraint(equalTo: view_text.trailingAnchor, constant: -8),
                txt_comment.topAnchor.constraint(equalTo: view_text.topAnchor, constant: 8),
                txt_comment.bottomAnchor.constraint(equalTo: view_text.bottomAnchor, constant: -8)
            ])
            
            print("Constraints set up for view_text and textField")
        }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
      }
      
    /*@objc func keyboardWillShow(_ notification: Notification) {
            print("Keyboard will show")
            
            if let userInfo = notification.userInfo,
               let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                
                let keyboardHeight = keyboardFrame.height
                let bottomInset = view.safeAreaInsets.bottom
                
                // Adjust the view_text's bottom constraint
                viewTextBottomConstraint.constant = -keyboardHeight + bottomInset
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        @objc func keyboardWillHide(_ notification: Notification) {
            print("Keyboard will hide")
            
            // Reset the view_text's bottom constraint
            viewTextBottomConstraint.constant = -20
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }*/
    
}

//MARK:- TABLE VIEW -
extension comments: UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_comment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:comments_table_cell = tableView.dequeueReusableCell(withIdentifier: "comments_table_cell") as! comments_table_cell
        
        cell.backgroundColor = .clear
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
        
        let item = self.arr_comment[indexPath.row] as? [String:Any]
        cell.lbl_username.text = (item!["userName"] as! String)
        cell.lbl_comment_message.text = (item!["comment"] as! String)
        
        cell.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.img_profile.sd_setImage(with: URL(string: (item!["profile_picture"] as! String)), placeholderImage: UIImage(named: "1024"))
        
        return cell
        
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

class comments_table_cell : UITableViewCell {
    
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
    
    @IBOutlet weak var lbl_comment_message:UILabel! {
        didSet {
            lbl_comment_message.textColor = .white
        }
    }
     
}
