//
//  product_details.swift
//  LYV
//
//  Created by Dishant Rajput on 01/08/24.
//

import UIKit
import SDWebImage
import Alamofire

class product_details: UIViewController {

    var dict_product_details:NSDictionary!
    
    var str_select_color:String! = "0"
    var str_select_size:String! = "0"
    
    let reverseColorDictionary: [String: String] = {
        var dict = [String: String]()
        for (key, value) in colorDictionary {
            dict[value] = key
        }
        return dict
    }()

    
    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.tintColor = .white
            btn_back.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var tble_view:UITableView! {
        didSet {
            tble_view.backgroundColor = .clear
            tble_view.delegate = self
            tble_view.dataSource = self
        }
    }
    
    @IBOutlet weak var btn_cart:UIButton! {
        didSet {
            btn_cart.isHidden = true
        }
    }
    
    @IBOutlet weak var btn_heart:UIButton! {
        didSet {
            btn_heart.isHidden = false
        }
    }
    
    @IBOutlet weak var lbl_cart_counter:UILabel!  {
        didSet {
            lbl_cart_counter.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = app_BG
        
        print(self.dict_product_details as Any)
        
        if (self.dict_product_details["ulike"] as! String) == "No" {
            self.btn_heart.tag = 0
            self.btn_heart.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            self.btn_heart.tag = 1
            self.btn_heart.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        
        self.btn_heart.addTarget(self, action: #selector(heart_click_method), for: .touchUpInside)
        
        self.btn_cart.addTarget(self, action: #selector(push_to_Cart), for: .touchUpInside)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.cart_counter_WB()
    }
    
    @objc func push_to_Cart() {
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "cart_list_id")
        self.navigationController?.pushViewController(push, animated: true)
    }
    
    
    @objc func colors_click_method() {
        
        let indexPath = IndexPath.init(row: 4, section: 0)
        let cell = self.tble_view.cellForRow(at: indexPath) as! product_details_table_cell
        
        let colorNames = getColorNames(from: (self.dict_product_details["color"] as! String))
        let dummyList = colorNames
        
        RPicker.selectOption(title: "Color", cancelText: "Dismiss", dataArray: dummyList, selectedIndex: 0) { (selctedText, atIndex) in
             
            cell.btn_colors.setTitle(String(selctedText), for: .normal)
            self.str_select_color = String(selctedText)
            
        }
        
    }
    
    func getColorNames(from colorCodes: String) -> [String] {
        // Split the colorCodes string into an array of codes
        let codes = colorCodes.split(separator: ",").map { String($0) }
        var colorNames: [String] = []
        
        // Iterate over the color codes and get the corresponding color names
        for code in codes {
            if let colorName = colorDictionary[code] {
                colorNames.append(colorName)
            }
        }
        
        return colorNames
    }

    
    @objc func size_click_method() {
        
        let indexPath = IndexPath.init(row: 4, section: 0)
        let cell = self.tble_view.cellForRow(at: indexPath) as! product_details_table_cell
        
        let colorCodesString = (self.dict_product_details["size"] as! String)
        let colorCodesArray = colorCodesString.split(separator: ",").map { String($0) }
        // print(colorCodesArray)
        let dummyList = colorCodesArray
        
        RPicker.selectOption(title: "Size", cancelText: "Dismiss", dataArray: dummyList, selectedIndex: 0) { (selctedText, atIndex) in
             
            cell.btn_sizes.setTitle(String(selctedText), for: .normal)
            self.str_select_size = String(selctedText)
        }
        
    }
    
    
    
    @objc func cart_counter_WB() {
       
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
                    "action"    : "cartlist",
                    "userId"    : String(myString),
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
                                
                                if (ar.count != 0) {
                                    self.btn_cart.isHidden = false
                                    self.lbl_cart_counter.isHidden = false
                                    self.lbl_cart_counter.text = "\(ar.count)"
                                } else {
                                    self.btn_cart.isHidden = true
                                    self.lbl_cart_counter.isHidden = true
                                }
                            } else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.cart_counter_WB()
                                        
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
                        
                        self.cart_counter_WB()
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    
    @objc func heart_click_method() {
        
        if (self.btn_heart.tag == 0) {
            self.btn_heart.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            self.btn_heart.tag = 1
            self.like_product_WB(like_status: "1")
        } else {
            self.btn_heart.tag = 0
            self.btn_heart.setImage(UIImage(systemName: "heart"), for: .normal)
            self.like_product_WB(like_status: "0")
        }
        
    }
    
    
    @objc func like_product_WB(like_status:String) {
       
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
                    "action"    : "productlike",
                    "userId"    : String(myString),
                    "productId" : "\(self.dict_product_details["productId"]!)",
                    "status"    : String(like_status),
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
                                        
                                        self.cart_counter_WB()
                                        
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
                        
                        self.cart_counter_WB()
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    /*
     [action] => cartadd
         [userId] => 16
         [productId] => 15
         [quantity] => 1
         [p_color] => 5
         [p_size] => M
     */
    
    func getColorCode(for colorName: String) -> String? {
        return reverseColorDictionary[colorName]
    }

    
    @objc func add_to_cart_WB() {
       
        if (self.str_select_color == "0") {
            return
        } else if (self.str_select_size == "0") {
            return
        }
        
        if let colorCode = getColorCode(for: String(self.str_select_color)) {
            print(colorCode)
            
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
                        "action"    : "cartadd",
                        "userId"    : String(myString),
                        "productId" : "\(self.dict_product_details["productId"]!)",
                        "quantity"  : String("1"),
                        "p_color"   : String(colorCode),
                        "p_size"    : String(self.str_select_size),
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
                                
                                    cart_counter_WB()
                                } else {
                                    TokenManager.shared.refresh_token_WB { token, error in
                                        if let token = token {
                                            print("Token received: \(token)")
                                            
                                            let str_token = "\(token)"
                                            UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                            UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                            
                                            self.cart_counter_WB()
                                            
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
                            
                            self.cart_counter_WB()
                            
                        } else if let error = error {
                            print("Failed to refresh token: \(error.localizedDescription)")
                            // Handle the error
                        }
                    }
                }
            }
            
        } else {
            print("Color not found.")
        }
        
        
    }
}


//MARK:- TABLE VIEW -
extension product_details: UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell:product_details_table_cell = tableView.dequeueReusableCell(withIdentifier: "one") as! product_details_table_cell
            
            cell.backgroundColor = .clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
            
            cell.lbl_product_name.text = (self.dict_product_details["name"] as! String)
            
            return cell
            
        } else if (indexPath.row == 1) {
            let cell:product_details_table_cell = tableView.dequeueReusableCell(withIdentifier: "two") as! product_details_table_cell
            
            cell.backgroundColor = .clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
            
            cell.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.img_profile.sd_setImage(with: URL(string: (self.dict_product_details!["image_1"] as! String)), placeholderImage: UIImage(named: "1024"))
            
            return cell
            
        } else if (indexPath.row == 2) {
            let cell:product_details_table_cell = tableView.dequeueReusableCell(withIdentifier: "three") as! product_details_table_cell
            
            cell.backgroundColor = .clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
            
            cell.lbl_product_description.text = (self.dict_product_details["description"] as! String)
            
            return cell
            
        } else if (indexPath.row == 3) {
            let cell:product_details_table_cell = tableView.dequeueReusableCell(withIdentifier: "four") as! product_details_table_cell
            
            cell.backgroundColor = .clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
            
            cell.lbl_product_price.text = "$\(self.dict_product_details["price"]!)"
            
            return cell
            
        } else if (indexPath.row == 4) {
            let cell:product_details_table_cell = tableView.dequeueReusableCell(withIdentifier: "five") as! product_details_table_cell
            
            cell.backgroundColor = .clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
            
            cell.btn_colors.addTarget(self, action: #selector(colors_click_method), for: .touchUpInside)
            cell.btn_sizes.addTarget(self, action: #selector(size_click_method), for: .touchUpInside)
            
            cell.btn_add_to_cart.addTarget(self, action: #selector(add_to_cart_WB), for: .touchUpInside)
            
            return cell
            
        } else {
            let cell:product_details_table_cell = tableView.dequeueReusableCell(withIdentifier: "one") as! product_details_table_cell
            
            cell.backgroundColor = .clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return UITableView.automaticDimension
        } else if (indexPath.row == 1) {
            return 420
        } else if (indexPath.row == 2) {
            return UITableView.automaticDimension
        } else if (indexPath.row == 3) {
            return UITableView.automaticDimension
        } else if (indexPath.row == 4) {
            return 140
        } else {
            return 40
        }
        
    }

}

class product_details_table_cell : UITableViewCell {
    
    @IBOutlet weak var img_profile:UIImageView! {
        didSet {
            img_profile.layer.cornerRadius = 25
            img_profile.clipsToBounds = true
            img_profile.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var lbl_product_name:UILabel! {
        didSet {
            lbl_product_name.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_product_description:UILabel! {
        didSet {
            lbl_product_description.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_product_price:UILabel! {
        didSet {
            lbl_product_price.textColor = .white
        }
    }
    
    @IBOutlet weak var btn_colors:UIButton! {
        didSet {
            btn_colors.layer.cornerRadius = 20
            btn_colors.clipsToBounds = true
            btn_colors.backgroundColor = .clear
            btn_colors.setTitle("COLORS", for: .normal)
            btn_colors.layer.borderWidth = 0.4
            btn_colors.layer.borderColor = UIColor.darkGray.cgColor
        }
    }
    
    @IBOutlet weak var btn_sizes:UIButton! {
        didSet {
            btn_sizes.layer.cornerRadius = 20
            btn_sizes.clipsToBounds = true
            btn_sizes.backgroundColor = .clear
            btn_sizes.setTitle("SIZES", for: .normal)
            btn_sizes.layer.borderWidth = 0.4
            btn_sizes.layer.borderColor = UIColor.darkGray.cgColor
        }
    }
    
    @IBOutlet weak var btn_add_to_cart:UIButton! {
        didSet {
            btn_add_to_cart.backgroundColor = .white
            btn_add_to_cart.layer.cornerRadius = 25
            btn_add_to_cart.clipsToBounds = true
            btn_add_to_cart.setTitle("Add to Cart", for: .normal)
            btn_add_to_cart.backgroundColor = app_purple_color
            btn_add_to_cart.setTitleColor(.white, for: .normal)
        }
    }
    
}
