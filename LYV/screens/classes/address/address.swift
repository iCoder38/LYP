//
//  address.swift
//  LYV
//
//  Created by Dishant Rajput on 02/08/24.
//

import UIKit
import Alamofire

class address: UIViewController {

    var str_total_price:String!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = app_BG
        
        self.tble_view.reloadData()
    }
 
    
    func setPlaceholderColor(textField: UITextField, placeholder: String, color: UIColor) {
        textField.textColor = .white
        textField.backgroundColor = .clear
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    
    
    @objc func checkout_WB(loader:String) {
       
        let indexPath = IndexPath.init(row: 0, section: 0)
        let cell = self.tble_view.cellForRow(at: indexPath) as! address_table_cell
        
        if (cell.txt_full_name.text == "") {
            return
        } else if (cell.txt_address.text == "") {
            return
        } else if (cell.txt_city.text == "") {
            return
        } else if (cell.txt_zipcode.text == "") {
            return
        } else if (cell.txt_country.text == "") {
            return
        }
        
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
                
                /*
                 [action] => orderadd
                     [userId] => 17
                     [totalAmount] => 0
                     [transactionId] => 1722519215942
                     [S_name] => purnima pandey
                     [S_address] => c 5, surya appt
                     [S_City] => Ghaziabad
                     [S_State] => india
                     [S_pincode] => 201011
                     [shiping_cost] => 0
                 */
                
                parameters = [
                    "action"            : "orderadd",
                    "userId"            : String(myString),
                    "totalAmount"       : String(self.str_total_price),
                    "transactionId"     : "194837264728",
                    "S_name"            : String(cell.txt_full_name.text!),
                    "S_address"         : String(cell.txt_address.text!),
                    "S_City"            : String(cell.txt_city.text!),
                    "S_State"           : String(cell.txt_country.text!),
                    "S_pincode"         : String(cell.txt_zipcode.text!),
                    "shiping_cost"      : "0",
                   
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
                                
                                let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "checkout_id")
                                self.navigationController?.pushViewController(push, animated: true)
                                
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.checkout_WB(loader: "no")
                                        
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
                        
                        self.checkout_WB(loader: "no")
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    @objc func next_click_method() {
        checkout_WB(loader: "yes")
    }
}


//MARK:- TABLE VIEW -
extension address: UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:address_table_cell = tableView.dequeueReusableCell(withIdentifier: "address_table_cell") as! address_table_cell
        
        cell.backgroundColor = .clear
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
        
        setPlaceholderColor(textField: cell.txt_full_name, placeholder: "Full Name", color: .white)
        setPlaceholderColor(textField: cell.txt_address, placeholder: "Address", color: .white)
        setPlaceholderColor(textField: cell.txt_city, placeholder: "City", color: .white)
        setPlaceholderColor(textField: cell.txt_zipcode, placeholder: "Zipcode", color: .white)
        setPlaceholderColor(textField: cell.txt_country, placeholder: "Country", color: .white)
        // setPlaceholderColor(textField: cell.txt_shipping_method, placeholder: "Shipping Method", color: .white)
        
        cell.btn_next.addTarget(self, action: #selector(next_click_method), for: .touchUpInside)
        
        return cell
        
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1200
    }

}

class address_table_cell : UITableViewCell {
    
    @IBOutlet weak var btn_next:UIButton! {
        didSet {
            btn_next.backgroundColor = .white
            btn_next.layer.cornerRadius = 25
            btn_next.clipsToBounds = true
            btn_next.setTitle("NEXT", for: .normal)
            btn_next.backgroundColor = app_purple_color
            btn_next.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBOutlet weak var txt_full_name:UITextField!
    @IBOutlet weak var txt_address:UITextField!
    @IBOutlet weak var txt_city:UITextField!
    @IBOutlet weak var txt_zipcode:UITextField! {
        didSet {
            txt_zipcode.keyboardType = .numberPad
        }
    }
    
    @IBOutlet weak var txt_country:UITextField!
    @IBOutlet weak var txt_shipping_method:UITextField!
    
}
