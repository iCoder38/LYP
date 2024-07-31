//
//  home.swift
//  LYV
//
//  Created by Dishant Rajput on 29/07/24.
//

import UIKit
import Alamofire
import SDWebImage
import AVKit
import AVFoundation

class home: UIViewController {

    var arr_feeds:NSMutableArray! = []
    
    @IBOutlet weak var tble_view:UITableView! {
        didSet {
            tble_view.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var txt_search:UITextField! {
        didSet {
            txt_search.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_search.layer.cornerRadius = 25
            txt_search.clipsToBounds = true
            txt_search.placeholder = "Search"
            txt_search.setLeftPaddingPoints(20)
            let placeholderText = "Search"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_search.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        }
    }
    
    @IBOutlet weak var img_profile:UIImageView! {
        didSet {
            img_profile.layer.cornerRadius = 25
            img_profile.clipsToBounds = true
            img_profile.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var btn_view_all:UIButton! {
        didSet {
            btn_view_all.setTitleColor(app_purple_color, for: .normal)
        }
    }
    
    @IBOutlet weak var collectionView:UICollectionView! {
        didSet {
            collectionView.isPagingEnabled = false
            collectionView.backgroundColor = .clear
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.feeds_list_WB(loader: "yes")
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
                    // "type"      : "own",
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
                                
                                self.collectionView.delegate = self
                                self.collectionView.dataSource = self
                                self.collectionView.reloadData()
                                
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
extension home: UITableViewDataSource , UITableViewDelegate {
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

class home_table_cell : UITableViewCell {
    
    @IBOutlet weak var img_profile:UIImageView! {
        didSet {
            img_profile.layer.cornerRadius = 25
            img_profile.clipsToBounds = true
            img_profile.backgroundColor = .brown
        }
    }
    
    @IBOutlet weak var lbl_username:UILabel!
    @IBOutlet weak var lbl_time:UILabel!
    @IBOutlet weak var lbl_tags:UILabel!
    @IBOutlet weak var lbl_description:UILabel!
    
    @IBOutlet weak var lbl_likes:UILabel!
    @IBOutlet weak var btn_like:UIButton!
    
    @IBOutlet weak var lbl_comments:UILabel!
    
    @IBOutlet weak var img_feed_image:UIImageView! {
        didSet {
            img_feed_image.layer.cornerRadius = 16
            img_feed_image.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var btn_play:UIButton!
    
    @IBOutlet weak var btn_comment:UIButton!
}

//MARK:- COLLECTION VIEW -
extension home: UICollectionViewDelegate ,
                     UICollectionViewDataSource ,
                     UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_collection_view_cell", for: indexPath as IndexPath) as! home_collection_view_cell

        cell.backgroundColor  = .clear
        
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
        sizes = CGSize(width: 140, height: 140)
        
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
        
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
}

class home_collection_view_cell: UICollectionViewCell , UITextFieldDelegate {
    
    @IBOutlet weak var img_view:UIImageView! {
        didSet {
            img_view.layer.cornerRadius = 12
            img_view.clipsToBounds = true
            img_view.backgroundColor = .brown
        }
    }
    
}


