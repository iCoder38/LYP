//
//  shop_details.swift
//  LYV
//
//  Created by Dishant Rajput on 31/07/24.
//

import UIKit
import Alamofire
import SDWebImage

class shop_details: UIViewController {

    var str_nav_name:String!
    var get_details:NSDictionary!
    
    var arr_category:NSMutableArray! = []
    var arr_category_products:NSMutableArray! = []
    var str_product_id:String!
    
    
    
    @IBOutlet weak var lbl_nav:UILabel! {
        didSet {
            lbl_nav.textColor = .white
        }
    }
    
    @IBOutlet weak var collectionView1:UICollectionView! {
        didSet {
            collectionView1.isPagingEnabled = false
            collectionView1.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var collectionView2:UICollectionView! {
        didSet {
            collectionView2.isPagingEnabled = false
            collectionView2.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.tintColor = .white
            btn_back.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = app_BG
        
        self.lbl_nav.text = String(self.str_nav_name)
        
        var ar2 : NSArray!
        ar2 = (self.get_details!["child"] as! Array<Any>) as NSArray
        // self.arr_category.addObjects(from: ar2 as! [Any])
        
        for indexx in 0..<ar2.count{
            let item = ar2[indexx] as? [String:Any]
            
            if (indexx == 0) {
                let custom = [
                    "id"        : "\(item!["id"]!)",
                    "name"      : (item!["name"] as! String),
                    "status"    : "yes",
                ]
                self.arr_category.add(custom)
                
                self.str_product_id = "\(item!["id"]!)"
                
            } else {
                let custom = [
                    "id"        : "\(item!["id"]!)",
                    "name"      : (item!["name"] as! String),
                    "status"    : "no",
                ]
                self.arr_category.add(custom)
            }
            
        }
        
        self.product_list_WB(loader: "yes")
        
        self.collectionView1.delegate = self
        self.collectionView1.dataSource = self
        self.collectionView1.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.product_list_WB(loader: "yes")
    }
    
    @objc func product_list_WB(loader:String) {
       
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
                    "action"    : "productlist",
                    "userId"    : String(myString),
                    "category"    : String(self.str_product_id),
                    // "status"    : String(status),
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
                                
                                self.arr_category_products.removeAllObjects()
                                
                                self.arr_category_products.addObjects(from: ar as! [Any])
                                print(self.arr_category_products.count)
                                
                                if (self.arr_category_products.count != 0) {
                                    self.collectionView2.isHidden = false
                                    self.collectionView2.delegate = self
                                    self.collectionView2.dataSource = self
                                    self.collectionView2.reloadData()
                                } else {
                                    self.collectionView2.isHidden = true
                                }
//
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.product_list_WB(loader: "no")
                                        
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
                        
                        self.product_list_WB(loader: "no")
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    
    @objc func likeItemClickMethod(_ sender:UIButton) {
        let item = self.arr_category_products[sender.tag] as? [String:Any]
        print(item as Any)
        
        var status:String!
        
        if "\(item!["ulike"]!)" == "No" {
            status = "1"
        } else {
            status = "0"
        }
        
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
                    "productId" : "\(item!["productId"]!)",
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
                            
                                self.product_list_WB(loader: "no")
//
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        // self.product_list_WB()
                                        
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
                        
                        // self.likeItemClickMethod()
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
}


//MARK:- COLLECTION VIEW -
extension shop_details: UICollectionViewDelegate ,
                     UICollectionViewDataSource ,
                     UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (collectionView == collectionView1) {
            return self.arr_category.count
        } else {
            return self.arr_category_products.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (collectionView == collectionView1) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shop_details_view_cell", for: indexPath as IndexPath) as! shop_details_view_cell

            let item = self.arr_category[indexPath.row] as? [String:Any]
            cell.myLabel.text = (item!["name"] as! String)
            
            if (item!["status"] as! String) == "no" {
                
                cell.backgroundColor = app_BG
                cell.layer.cornerRadius = 12
                cell.clipsToBounds = true
                cell.layer.borderWidth = 0.6
                cell.layer.borderColor = UIColor.white.cgColor
                cell.myLabel.textColor = .white
                
            } else {
                
                cell.backgroundColor = .white
                cell.layer.cornerRadius = 12
                cell.clipsToBounds = true
                cell.layer.borderWidth = 0.6
                cell.layer.borderColor = UIColor.white.cgColor
                cell.myLabel.textColor = .black
                
            }
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shop_details_view_cell2", for: indexPath as IndexPath) as! shop_details_view_cell2

            let item = self.arr_category_products[indexPath.row] as? [String:Any]
           
            cell.lbl_price.text = "$\(item!["price"]!)"
            cell.img_details.text = "\(item!["name"]!)"
            
            cell.img_product_image.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.img_product_image.sd_setImage(with: URL(string: (item!["image_1"] as! String)), placeholderImage: UIImage(named: "1024"))
            
            cell.configure(with: "\(item!["color"]!)")
            
            cell.btnLike.tag = indexPath.row
            cell.btnLike.addTarget(self, action: #selector(likeItemClickMethod), for: .touchUpInside)
            
            if "\(item!["ulike"]!)" == "No" {
                cell.btnLike.setImage(UIImage(systemName: "heart"), for: .normal)
                cell.btnLike.tintColor = .darkGray
            } else {
                cell.btnLike.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                cell.btnLike.tintColor = .systemPink
            }
            /*let colorNames = getColorNames(from: "\(item!["color"]!)")
            if let firstColorName = colorNames.first, let color = getColor(from: firstColorName) {
                cell.colorDotView.backgroundColor = color
            }*/
            
            /*let colorCodesString = "\(item!["color"]!)"
            let colorCodesArray = colorCodesString.split(separator: ",").map { String($0) }
            print(colorCodesArray)
            let colorCodes = colorCodesArray[indexPath.row]
            let colorNames = getColorNames(from: colorCodes)
            if let firstColorName = colorNames.first, let color = getColor(from: firstColorName) {
                cell.colorDotView.backgroundColor = color
            }*/
            
            return cell
        }
        
    }
    
    // Helper function to convert color name to UIColor
        func getColor(from colorName: String) -> UIColor? {
            switch colorName.lowercased() {
            case "red":
                return UIColor.red
            case "green":
                return UIColor.green
            case "yellow":
                return UIColor.yellow
            case "blue":
                return UIColor.blue
            case "sky-blue":
                return UIColor.systemTeal
            case "brown":
                return UIColor.brown
            case "pink":
                return UIColor.systemPink
            case "purple":
                return UIColor.purple
            case "magenta":
                return UIColor.magenta
            case "orange":
                return UIColor.orange
            case "white":
                return UIColor.white
            default:
                return nil
            }
        }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (collectionView == collectionView1) {
            for indexx in 0..<self.arr_category.count {
                
                let item2 = self.arr_category[indexx] as? [String:Any]
                
                if (indexx == indexPath.row) {
                   
                    let custom = [
                        "id"        : (item2!["id"] as! String),
                        "name"      : (item2!["name"] as! String),
                        "status"    : "yes",
                    ]
                    
                    self.arr_category.removeObject(at: indexx)
                    self.arr_category.insert(custom, at: indexx)
                    
                    self.str_product_id = (item2!["id"] as! String)
                } else {
                  
                    let custom = [
                        "id"        : (item2!["id"] as! String),
                        "name"      : (item2!["name"] as! String),
                        "status"    : "no",
                    ]
                    
                    self.arr_category.removeObject(at: indexx)
                    self.arr_category.insert(custom, at: indexx)
                }
               
            }
            
            print(self.arr_category as Any)
            self.collectionView1.reloadData()
            self.product_list_WB(loader: "no")
            
        } else {
            let item = self.arr_category_products[indexPath.row] as? [String:Any]
            let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "product_details_id") as? product_details
            push!.dict_product_details = (item! as NSDictionary)
            self.navigationController?.pushViewController(push!, animated: true)
        }
        
    
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (collectionView == collectionView1) {
            var sizes: CGSize
            let result = UIScreen.main.bounds.size
            NSLog("%f",result.height)
            sizes = CGSize(width: self.view.frame.size.width/3, height: 40)
            
            return sizes
        } else {
            var sizes: CGSize
            let result = UIScreen.main.bounds.size
            NSLog("%f",result.height)
            sizes = CGSize(width: (self.view.frame.size.width/2)-20, height: 330)
            
            return sizes
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
    }
    
}

class shop_details_view_cell: UICollectionViewCell , UITextFieldDelegate {
    
    @IBOutlet weak var lbl_title:UILabel! {
        didSet {
            lbl_title.textColor = .white
            lbl_title.isHidden = true
            
        }
    }
    
    let myLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }
    
    
    private func setupLabel() {
        contentView.addSubview(myLabel)
        
        // Set constraints for the label
        NSLayoutConstraint.activate([
            myLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            myLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            myLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            myLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
   
}

class shop_details_view_cell2: UICollectionViewCell {
    @IBOutlet weak var btnLike:UIButton!
    @IBOutlet weak var img_product_image:UIImageView!  {
        didSet {
            img_product_image.layer.cornerRadius = 12
            img_product_image.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var img_details:UILabel! {
        didSet {
            img_details.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_price:UILabel!  {
        didSet {
            lbl_price.textColor = .white
        }
    }
    
    @IBOutlet weak var colorDotView: UIView!
    
    @IBOutlet weak var colorsStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with colorCodes: String) {
        setupColorDots(from: colorCodes)
    }
    
    private func setupColorDots(from colorCodes: String) {
        // Remove existing color dot views
        colorsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let colorNames = getColorNames(from: colorCodes)
        
        let dotSize: CGFloat = 8
        let dotSpacing: CGFloat = 4
        
        for colorName in colorNames {
            if let color = getColor(from: colorName) {
                let dotView = UIView()
                dotView.backgroundColor = color
                dotView.translatesAutoresizingMaskIntoConstraints = false
                dotView.widthAnchor.constraint(equalToConstant: dotSize).isActive = true
                dotView.heightAnchor.constraint(equalToConstant: dotSize).isActive = true
                dotView.layer.cornerRadius = dotSize / 2 // Half of the width/height to make it a circle
                dotView.clipsToBounds = true
                colorsStackView.addArrangedSubview(dotView)
            }
        }
        
        // Ensure the stack view arranges dots in a horizontal line
        colorsStackView.axis = .horizontal
        colorsStackView.spacing = dotSpacing // Adjust spacing as needed
        colorsStackView.distribution = .fillEqually
    }
    
    // Helper function to convert color name to UIColor
    private func getColor(from colorName: String) -> UIColor? {
        switch colorName.lowercased() {
        case "red":
            return UIColor.red
        case "green":
            return UIColor.green
        case "yellow":
            return UIColor.yellow
        case "blue":
            return UIColor.blue
        case "sky-blue":
            return UIColor.systemTeal
        case "brown":
            return UIColor.brown
        case "pink":
            return UIColor.systemPink
        case "purple":
            return UIColor.purple
        case "magenta":
            return UIColor.magenta
        case "orange":
            return UIColor.orange
        case "white":
            return UIColor.white
        default:
            return nil
        }
    }
    
}

struct CustomItem {
    let name: String
    let colorCodes: String
}
