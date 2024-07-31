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
    
    @IBOutlet weak var lbl_nav:UILabel! {
        didSet {
            lbl_nav.textColor = .white
        }
    }
    
    @IBOutlet weak var collectionView:UICollectionView! {
        didSet {
            collectionView.isPagingEnabled = false
            collectionView.backgroundColor = .clear
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
                var custom = [
                    "name"      : (item!["name"] as! String),
                    "status"    : "yes",
                ]
                self.arr_category.add(custom)
            } else {
                var custom = [
                    "name"      : (item!["name"] as! String),
                    "status"    : "no",
                ]
                self.arr_category.add(custom)
            }
            
            
        }
        
        // print(self.arr_category as Any)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
    }
    
    
    /*@objc func like_dislike_WB(status:String,postId:String) {
       
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
        
    }*/
    
}


//MARK:- COLLECTION VIEW -
extension shop_details: UICollectionViewDelegate ,
                     UICollectionViewDataSource ,
                     UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arr_category.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shop_details_view_cell", for: indexPath as IndexPath) as! shop_details_view_cell

        
        
        let item = self.arr_category[indexPath.row] as? [String:Any]
        cell.myLabel.text = (item!["name"] as! String)
        
        if (item!["status"] as! String) == "no" {
            
            cell.backgroundColor  = app_BG
            cell.layer.cornerRadius = 12
            cell.clipsToBounds = true
            cell.layer.borderWidth = 0.6
            cell.layer.borderColor = UIColor.white.cgColor
            cell.myLabel.textColor = .white
            
        } else {
            
            cell.backgroundColor  = .white
            cell.layer.cornerRadius = 12
            cell.clipsToBounds = true
            cell.layer.borderWidth = 0.6
            cell.layer.borderColor = UIColor.white.cgColor
            cell.myLabel.textColor = .black
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var sizes: CGSize
        let result = UIScreen.main.bounds.size
        NSLog("%f",result.height)
        sizes = CGSize(width: self.view.frame.size.width/3, height: 40)
        
        return sizes
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
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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


