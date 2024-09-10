//
//  follow_followers.swift
//  LYV
//
//  Created by Dishant Rajput on 10/09/24.
//

import UIKit
import Alamofire
import SDWebImage

class follow_followers: UIViewController {
    
    var strType:String!
    
    var arrNotificationsList:NSMutableArray! = []
    @IBOutlet weak var navigationTitle:UILabel!
    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.isHidden = false
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
        self.view.backgroundColor = app_BG
        
        if (self.strType != "A") {
            self.navigationTitle.text = "Following"
        } else {
            self.navigationTitle.text = "Followers"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.followFollowerListWB(loader: "yes")
    }
    
    @objc func followFollowerListWB(loader:String) {
       
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
                    "action"    : "followlist",
                    "userId"    : String(myString),
                    "type"      : String(strType)
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
                                
                                self.arrNotificationsList.removeAllObjects()
                                self.arrNotificationsList.addObjects(from: ar as! [Any])
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
                                        
                                        self.followFollowerListWB(loader: "no")
                                        
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
                        
                        self.followFollowerListWB(loader: "no")
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    
    func createInitialString(for text: String) -> String {
        // Extract the first character and capitalize it
        if let firstCharacter = text.first {
            return String(firstCharacter).uppercased()
        }
        
        return "" // Return an empty string if no first character
    }
    
    // Function to extract the first initial and apply a random background color to the label
    func configureInitialLabel(label: UILabel, withText text: String) {
        // Extract the first character and capitalize it
        if let firstCharacter = text.first {
            label.text = String(firstCharacter).uppercased()
        } else {
            label.text = "" // Set an empty string if the input text is empty
        }
        
        // Randomly generate a background color
        let randomColor = UIColor(
            red: CGFloat(arc4random_uniform(256)) / 255.0,
            green: CGFloat(arc4random_uniform(256)) / 255.0,
            blue: CGFloat(arc4random_uniform(256)) / 255.0,
            alpha: 1.0
        )
        
        // Apply the random background color to the label
        label.backgroundColor = randomColor
        
        // Additional label styling
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = label.frame.size.height / 2
        label.clipsToBounds = true
    }
    
}


//MARK:- TABLE VIEW -
extension follow_followers: UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrNotificationsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:follow_followers_table_cell = tableView.dequeueReusableCell(withIdentifier: "follow_followers_table_cell") as! follow_followers_table_cell
        
        cell.backgroundColor = .clear
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
        
        let item = self.arrNotificationsList[indexPath.row] as? [String:Any]
        
        let userName = (item!["userName"] as! String)
        let userEmail = (item!["userEmail"] as! String)
        let userImage = (item!["profile_picture"] as! String)
        
        cell.lblUsername.text = userName
        cell.lblUsernameEmail.text = userEmail
        
        cell.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.imgProfile.sd_setImage(with: URL(string: userImage), placeholderImage: UIImage(named: "1024"))
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

class follow_followers_table_cell : UITableViewCell {
    
    @IBOutlet weak var imgProfile:UIImageView! {
        didSet {
            imgProfile.layer.cornerRadius = 6
            imgProfile.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var lblUsername:UILabel!
    @IBOutlet weak var lblUsernameEmail:UILabel!
    
}
