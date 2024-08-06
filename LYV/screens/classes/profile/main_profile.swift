//
//  main_profile.swift
//  LYV
//
//  Created by Dishant Rajput on 05/08/24.
//

import UIKit

class main_profile: UIViewController {

    var arr_profile = ["My Profile","Change password","My order","Wishlist","Logout"]
    var arr_profile_name = ["person","lock","newspaper","heart.fill","lock"]
    
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
            
            let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "my_profile_id") as? my_profile
            self.navigationController?.pushViewController(push!, animated: true)
            
        } else  if (indexPath.row == 1) {
            
            let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "change_password_id") as? change_password
            self.navigationController?.pushViewController(push!, animated: true)
            
        } else  if (indexPath.row == 2) {
            
            let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "my_orders_id") as? my_orders
            self.navigationController?.pushViewController(push!, animated: true)
            
        } else if (indexPath.row == 4) {
            
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
