//
//  details.swift
//  LYV
//
//  Created by Dishant Rajput on 05/08/24.
//

import UIKit
import SDWebImage

class details: UIViewController {

    var dict_product_details:NSDictionary!
    
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
    }
    
}

//MARK:- TABLE VIEW -
extension details: UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell:details_table_cell = tableView.dequeueReusableCell(withIdentifier: "one") as! details_table_cell
            
            cell.backgroundColor = .clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
            
            cell.lbl_product_name.text = (self.dict_product_details["p_name"] as! String)
            
            return cell
            
        } else if (indexPath.row == 1) {
            let cell:details_table_cell = tableView.dequeueReusableCell(withIdentifier: "two") as! details_table_cell
            
            cell.backgroundColor = .clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
            
            cell.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.img_profile.sd_setImage(with: URL(string: (self.dict_product_details!["p_image_1"] as! String)), placeholderImage: UIImage(named: "1024"))
            
            return cell
            
        } else if (indexPath.row == 2) {
            let cell:details_table_cell = tableView.dequeueReusableCell(withIdentifier: "three") as! details_table_cell
            
            cell.backgroundColor = .clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
            
            cell.lbl_product_description.text = (self.dict_product_details["p_description"] as! String)
            
            return cell
            
        
        } else if (indexPath.row == 3) {
            let cell:details_table_cell = tableView.dequeueReusableCell(withIdentifier: "four") as! details_table_cell
            
            cell.backgroundColor = .clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
             
            cell.lbl_order_date.text = (self.dict_product_details["created"] as! String)
            cell.lbl_color.text = (self.dict_product_details["p_color"] as! String)
            cell.lbl_size.text = (self.dict_product_details["p_size"] as! String)
            cell.lbl_quantity.text = "\(self.dict_product_details["p_quantity"]!)"
            cell.lbl_price.text = (self.dict_product_details["created"] as! String)
            cell.lbl_address.text = (self.dict_product_details["S_address"] as! String)
            cell.lbl_total_price.text = "$\(self.dict_product_details["p_price"]!)"
            
            return cell
            
        
        } else {
            let cell:details_table_cell = tableView.dequeueReusableCell(withIdentifier: "one") as! details_table_cell
            
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
            return 228
        } else if (indexPath.row == 4) {
            return 140
        } else {
            return 40
        }
        
    }

}

class details_table_cell : UITableViewCell {
    
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
    
    
    
    @IBOutlet weak var lbl_order_date:UILabel! {
        didSet {
            lbl_order_date.textColor = .white
        }
    }
    @IBOutlet weak var lbl_color:UILabel! {
        didSet {
            lbl_color.textColor = .white
        }
    }
    @IBOutlet weak var lbl_size:UILabel! {
        didSet {
            lbl_size.textColor = .white
        }
    }
    @IBOutlet weak var lbl_quantity:UILabel! {
        didSet {
            lbl_quantity.textColor = .white
        }
    }
    @IBOutlet weak var lbl_price:UILabel! {
        didSet {
            lbl_price.textColor = .white
        }
    }
    @IBOutlet weak var lbl_address:UILabel! {
        didSet {
            lbl_address.textColor = .white
        }
    }
    @IBOutlet weak var lbl_total_price:UILabel! {
        didSet {
            lbl_total_price.textColor = .white
        }
    }
}
