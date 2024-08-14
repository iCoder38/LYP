//
//  cart_list.swift
//  LYV
//
//  Created by Dishant Rajput on 01/08/24.
//

import UIKit
import Alamofire
import SDWebImage

class cart_list: UIViewController {
    
    var arr_cart_list:NSMutableArray! = []
    
    var str_product_id_for_delete:String!
    var str_store_total_price:String!
    
    @IBOutlet weak var tble_view:UITableView! {
        didSet {
            tble_view.backgroundColor = .clear
        }
    }
    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.isHidden = false
            btn_back.tintColor = .white
            btn_back.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var btn_checkout:UIButton! {
        didSet {
            btn_checkout.backgroundColor = .white
            btn_checkout.layer.cornerRadius = 0
            btn_checkout.clipsToBounds = true
            btn_checkout.setTitle("Checkout", for: .normal)
            btn_checkout.backgroundColor = app_purple_color
            btn_checkout.setTitleColor(.white, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = app_BG
        
        self.cart_counter_WB(loader: "yes")
        
        self.btn_checkout.addTarget(self, action: #selector(checkout_address_click_method), for: .touchUpInside)
        
    }
    
    @objc func checkout_address_click_method() {
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "address_id") as? address
        push!.str_total_price = String(self.str_store_total_price)
        self.navigationController?.pushViewController(push!, animated: true)
    }
    
    
    @objc func cart_counter_WB(loader:String) {
        
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
                                
                                self.arr_cart_list.removeAllObjects()
                                self.arr_cart_list.addObjects(from: ar as! [Any])
                                
                                var total: Decimal = 0.0
                                for indexx in 0..<self.arr_cart_list.count {
                                    let item = self.arr_cart_list[indexx] as? [String:Any]
                                    
                                    if let price = Decimal(string: "\(item!["price"]!)") {
                                        var quantity = Decimal(string: "\(item!["quantity"]!)")
                                        total += price*quantity!
                                    }
                                }
                                
                                // var multiplyQuantityWithTotal = to
                                 print(total as Any)
                                
                                self.btn_checkout.setTitle("Checkout: $\(total)", for: .normal)
                                self.str_store_total_price = "\(total)"
                                
                                self.tble_view.delegate = self
                                self.tble_view.dataSource = self
                                self.tble_view.reloadData()
                                
                            } else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.cart_counter_WB(loader: "no")
                                        
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
                        
                        self.cart_counter_WB(loader: "no")
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    
    
    @objc func delete_item_in_cart_WB() {
        
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
                    "action"    : "cartdelete",
                    "userId"    : String(myString),
                    "productId"    : String(self.str_product_id_for_delete),
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
                                
                                self.cart_counter_WB(loader: "no")
                                
                            } else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.delete_item_in_cart_WB()
                                        
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
                        
                        self.delete_item_in_cart_WB()
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    @objc func addItemQuantityClick(_ sender:UIButton) {
        
        let item = self.arr_cart_list[sender.tag] as? [String:Any]
        self.str_product_id_for_delete = "\(item!["productId"]!)"
        
        
        self.addItemQuantityInExistingItemsWB(loader: "yes", quantity: (item!["quantity"] as! Int))
    }
    
    @objc func addItemQuantityInExistingItemsWB(loader:String,quantity:Int) {
        
        var addoneQuantity:Int! = 0
        
        addoneQuantity = quantity + 1
        
        
        
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
                    "action"    : "cartadd",
                    "userId"    : String(myString),
                    "productId" : String(self.str_product_id_for_delete),
                    "quantity"  : "\(addoneQuantity!)",
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
                                
                                self.cart_counter_WB(loader: "no")
                                
                            } else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.addItemQuantityInExistingItemsWB(loader: "no", quantity: quantity)
                                        
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
                        
                        self.addItemQuantityInExistingItemsWB(loader: "no", quantity: quantity)
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
        
        
    }
    
    
    @objc func minusItemQuantityClick(_ sender:UIButton) {
        
        let item = self.arr_cart_list[sender.tag] as? [String:Any]
        self.str_product_id_for_delete = "\(item!["productId"]!)"
        
        if "\(item!["quantity"]!)" == "1" {
            self.delete_item_in_cart_WB()
        } else {
            self.minusItemQuantityInExistingItemsWB(loader: "yes", quantity: (item!["quantity"] as! Int))
        }
    }
    
    @objc func minusItemQuantityInExistingItemsWB(loader:String,quantity:Int) {
        
        var addoneQuantity:Int! = 0
        
        addoneQuantity = quantity - 1
        
        
        
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
                    "action"    : "cartadd",
                    "userId"    : String(myString),
                    "productId" : String(self.str_product_id_for_delete),
                    "quantity"  : "\(addoneQuantity!)",
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
                                
                                self.cart_counter_WB(loader: "no")
                                
                            } else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.addItemQuantityInExistingItemsWB(loader: "no", quantity: quantity)
                                        
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
                        
                        self.addItemQuantityInExistingItemsWB(loader: "no", quantity: quantity)
                        
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
extension cart_list: UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_cart_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:cart_list_table_cell = tableView.dequeueReusableCell(withIdentifier: "cart_list_table_cell") as! cart_list_table_cell
        
        cell.backgroundColor = .clear
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
        
        let item = self.arr_cart_list[indexPath.row] as? [String:Any]
        
        cell.lbl_product_price.text = "$\(item!["price"]!) (\(item!["quantity"]!))"
        cell.lbl_product_title.text = "\(item!["name"]!)"
        
        cell.lbl_product_quantity.text = "\(item!["quantity"]!)"
        
        cell.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.img_profile.sd_setImage(with: URL(string: (item!["image_1"] as! String)), placeholderImage: UIImage(named: "1024"))
        
        cell.btnAddItemQuantity.tag = indexPath.row
        cell.btnMinusItemQuantity.tag = indexPath.row
        
        cell.btnAddItemQuantity.addTarget(self
                                          , action: #selector(addItemQuantityClick), for: .touchUpInside)
        
        cell.btnMinusItemQuantity.addTarget(self
                                          , action: #selector(minusItemQuantityClick), for: .touchUpInside)
        
        
        
        return cell
        
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
           
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            print(indexPath.row)
            let item = self.arr_cart_list[indexPath.row] as? [String:Any]
            print(item as Any)
            self.str_product_id_for_delete = "\(item!["productId"]!)"
            
            self.delete_item_in_cart_WB()
        }
    }
}

class cart_list_table_cell : UITableViewCell {
    
    @IBOutlet weak var img_profile:UIImageView! {
        didSet {
            img_profile.layer.cornerRadius = 8
            img_profile.clipsToBounds = true
            img_profile.backgroundColor = .white
        }
    }
    
    
    @IBOutlet weak var lbl_product_title:UILabel! {
        didSet {
            lbl_product_title.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_product_price:UILabel! {
        didSet {
            lbl_product_price.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_product_quantity:UILabel! {
        didSet {
            lbl_product_quantity.textAlignment = .center
            lbl_product_quantity.textColor = .white
            lbl_product_quantity.layer.cornerRadius = 4
            lbl_product_quantity.clipsToBounds = true
            lbl_product_quantity.backgroundColor = UIColor.init(red: 47.0/255.0, green: 48.0/255.0, blue: 52.0/255.0, alpha: 1)
        }
    }
   
    @IBOutlet weak var btnAddItemQuantity:UIButton! {
        didSet {
            btnAddItemQuantity.tintColor = .white
        }
    }
    
    @IBOutlet weak var btnMinusItemQuantity:UIButton! {
        didSet {
            btnMinusItemQuantity.tintColor = .white
        }
    }
    
    @IBOutlet weak var viewBG:UIView! {
        didSet {
            viewBG.backgroundColor = app_BG
            viewBG.layer.cornerRadius = 4
            viewBG.clipsToBounds = true
        }
    }
}
