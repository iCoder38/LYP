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
import Firebase

class home: UIViewController, UITextFieldDelegate {

    var liveArray:NSMutableArray! = []
    var arr_feeds:NSMutableArray! = []
    var arr_discover:NSMutableArray! = []
    
    var listener: ListenerRegistration?
    
    var userWhichIndex:String! = "0"
    var data: [String] = []
    var dataMutable:NSMutableArray! = []
    
    var strVideoKeyHit:Bool! = false
    
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
    
    @IBOutlet weak var btn_add:UIButton! {
        didSet {
            btn_add.layer.cornerRadius = 12
            btn_add.clipsToBounds = true
            btn_add.backgroundColor = app_purple_color
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txt_search.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        self.img_profile.isUserInteractionEnabled = true
        self.img_profile.addGestureRecognizer(tapGestureRecognizer)
        
        self.view.backgroundColor = app_BG
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        
        
        self.btn_add.addTarget(self
                               , action: #selector(add_c_m), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            // print(person)
            
            self.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            self.img_profile.sd_setImage(with: URL(string: (person["image"] as! String)), placeholderImage: UIImage(named: "1024"))
            
        }
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            print(person)
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            let myID = String(myString)
            // self.str_login_user_id = myID
            
            fetchFilteredData(myID: myID) { (dataArray, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let dataArray = dataArray {
                    print("Fetched data: \(dataArray)")
                    
                    self.feeds_list_WB(loader: "no")
                    
                }
            }
        }
        
    }
    
    func fetchFilteredData(myID: String, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        let db = Firestore.firestore()
        let collectionRef = db.collection(COLLECTION_PATH_LIVE_STREAM)
        
        let listener = collectionRef
            // .whereField("userId", isEqualTo: myID)
            .order(by: "timeStamp", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion(nil, error)
                    return
                }
                
                var dataArray: [[String: Any]] = []
                self.liveArray.removeAllObjects()
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    dataArray.append(data)
                    self.liveArray.add(data)
                }
                
                completion(dataArray, nil)
            }
        
        self.listener = listener
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    @objc func add_c_m() {
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "add_post_id") as? add_post
        self.navigationController?.pushViewController(push!, animated: true)
        
        
        
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
                                
                                DispatchQueue.main.async {
                                    self.tble_view.delegate = self
                                    self.tble_view.dataSource = self
                                    self.tble_view.reloadData()
                                }
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
    
    @objc func discover_WB() {
       
        var parameters:Dictionary<AnyHashable, Any>!
        
        // ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
      
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
                    "discover"    : String("1"),
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
                                
                                self.arr_discover.removeAllObjects()
                                self.arr_discover.addObjects(from: ar as! [Any])
                                print(self.arr_discover.count)
                                
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
                                        
                                        self.discover_WB()
                                        
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
                        
                        self.discover_WB()
                        
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
        return self.arr_feeds.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell:home_table_cell = tableView.dequeueReusableCell(withIdentifier: "one") as! home_table_cell
            
            cell.backgroundColor = .clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
            
            self.userWhichIndex = "0"
            
            cell.collectionView1.delegate = self
            cell.collectionView1.dataSource = self
            cell.collectionView1.reloadData()
            
            return cell
            
        } else {
            
            let item = self.arr_feeds[indexPath.row-1] as? [String:Any]
            let cell:home_table_cell = tableView.dequeueReusableCell(withIdentifier: "two") as! home_table_cell
            
            
            
            cell.backgroundColor = .clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
            
            cell.lbl_username.text = (item!["userName"] as! String)
            cell.lbl_description.text = item!["title"] as? String ?? ""
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
            
            
            cell.btn_like.tag = indexPath.row-1
            if (item!["ulike"] as! String) == "No" {
                cell.btn_like.addTarget(self, action: #selector(like_dislike_check_before_hit), for: .touchUpInside)
                cell.btn_like.setImage(UIImage(systemName: "heart"), for: .normal)
                cell.btn_like.tintColor = .gray
            } else {
                cell.btn_like.addTarget(self, action: #selector(like_dislike_check_before_hit), for: .touchUpInside)
                cell.btn_like.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                cell.btn_like.tintColor = .systemPink
            }
            
            cell.btn_comment.tag = indexPath.row-1
            cell.btn_comment.addTarget(self, action: #selector(comment_click_method), for: .touchUpInside)
            
            cell.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.img_profile.sd_setImage(with: URL(string: (item!["profile_picture"] as! String)), placeholderImage: UIImage(named: "1024"))
            
            self.userWhichIndex = "1"
             
                // Create array of image URLs, filtering out empty strings
                var images = [String]()
                if let image1 = item!["image_1"] as? String, !image1.isEmpty {
                    images.append(image1)
                }
                if let image2 = item!["image_2"] as? String, !image2.isEmpty {
                    images.append(image2)
                }
                if let image3 = item!["image_3"] as? String, !image3.isEmpty {
                    images.append(image3)
                }
                if let image4 = item!["image_4"] as? String, !image4.isEmpty {
                    images.append(image4)
                }
                if let image5 = item!["image_5"] as? String, !image5.isEmpty {
                    images.append(image5)
                }
                if let image6 = item!["image_6"] as? String, !image6.isEmpty {
                    images.append(image6)
                }
                if let image7 = item!["image_7"] as? String, !image7.isEmpty {
                    images.append(image7)
                }
                if let image8 = item!["image_8"] as? String, !image8.isEmpty {
                    images.append(image8)
                }
                if let image9 = item!["image_9"] as? String, !image9.isEmpty {
                    images.append(image9)
                }
                
                let videoUrl = item!["video"] as? String
                cell.videoUrl = videoUrl?.isEmpty == false ? videoUrl : nil
                
                // Check if there are any images or a video
                if images.isEmpty && (videoUrl == nil || videoUrl!.isEmpty) {
                    // No images or video, set the scroll view height to 0
                    cell.scrollViewHeight = 0
                    cell.lbl_description.textAlignment = .center
                } else {
                    // Images or video exist, set the scroll view height to 260 (or any preferred value)
                    cell.images = images
                    cell.scrollViewHeight = 260
                    cell.setupScrollViewImages()
                    cell.lbl_description.textAlignment = .left
                }
            
            
            
            
            
            return cell
            
        }
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "main_profile_id") as? main_profile
        self.navigationController?.pushViewController(push!, animated: true)
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
        if (indexPath.row == 0) {
            if (self.liveArray.count == 0) {
                return 0
            } else {
                return 200
            }
            
        } else {
            // return 394
            
            let item = self.arr_feeds[indexPath.row - 1] as! [String: Any]
                
                // Create array of image URLs, filtering out empty strings
                var images = [String]()
                if let image1 = item["image_1"] as? String, !image1.isEmpty {
                    images.append(image1)
                }
                if let image2 = item["image_2"] as? String, !image2.isEmpty {
                    images.append(image2)
                }
                if let image3 = item["image_3"] as? String, !image3.isEmpty {
                    images.append(image3)
                }
                if let image4 = item["image_4"] as? String, !image4.isEmpty {
                    images.append(image4)
                }
                if let image5 = item["image_5"] as? String, !image5.isEmpty {
                    images.append(image5)
                }
                if let image6 = item["image_6"] as? String, !image6.isEmpty {
                    images.append(image6)
                }
                if let image7 = item["image_7"] as? String, !image7.isEmpty {
                    images.append(image7)
                }
                if let image8 = item["image_8"] as? String, !image8.isEmpty {
                    images.append(image8)
                }
                if let image9 = item["image_9"] as? String, !image9.isEmpty {
                    images.append(image9)
                }
                
                let videoUrl = item["video"] as? String
                
                // If there are no images and no video, return the height without the scroll view
                if images.isEmpty && (videoUrl == nil || videoUrl!.isEmpty) {
                    return UITableView.automaticDimension
                }
                
                // Otherwise, return a height that includes the scroll view
                return 394
            
        }
        
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
    
    @IBOutlet weak var collectionView1:UICollectionView! {
        didSet {
            collectionView1.isPagingEnabled = false
            collectionView1.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var collectionView2:UICollectionView! {
        didSet {
            collectionView2.isPagingEnabled = true
            collectionView2.backgroundColor = .clear
            collectionView2.isScrollEnabled = true
        }
    }
    
    @IBOutlet weak var lbl_username:UILabel! {
        didSet {
            lbl_username.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_time:UILabel! {
        didSet {
            lbl_time.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_tags:UILabel! {
        didSet {
            lbl_tags.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_description:UILabel! {
        didSet {
            lbl_description.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_likes:UILabel! {
        didSet {
            lbl_likes.textColor = .white
        }
    }
    @IBOutlet weak var btn_like:UIButton! {
        didSet {
            
        }
    }
    
    @IBOutlet weak var lbl_comments:UILabel!  {
        didSet {
            lbl_comments.textColor = .white
        }
    }
    
    @IBOutlet weak var img_feed_image:UIImageView! {
        didSet {
            img_feed_image.layer.cornerRadius = 16
            img_feed_image.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var btn_play:UIButton!
    
    @IBOutlet weak var btn_comment:UIButton!
    
    @IBOutlet weak var scrollView2: UIScrollView!
    
        var scrollView: UIScrollView!
        
        // Variable to dynamically manage the scroll view height
        var scrollViewHeight: CGFloat = 260 {
            didSet {
                updateScrollViewHeight()
            }
        }
        
        // The images and video (if available)
        var images: [String] = []
        var videoUrl: String? = nil
        
        // Store the height constraint so we can update it dynamically
        private var scrollViewHeightConstraint: NSLayoutConstraint?

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupScrollView()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupScrollView()
        }
        
        // Function to set up the scroll view programmatically
        func setupScrollView() {
            scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.isPagingEnabled = false
            scrollView.bounces = true
            scrollView.backgroundColor = .clear
            
            contentView.addSubview(scrollView)
            
            // Set scroll view constraints with dynamic height
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor), // Full screen width
                scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor), // Full screen width
                scrollView.topAnchor.constraint(equalTo: lbl_description.bottomAnchor, constant: 10), // Below description label
            ])
            
            // Add the height constraint to the scroll view (initially set to scrollViewHeight)
            scrollViewHeightConstraint = scrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight)
            scrollViewHeightConstraint?.isActive = true
        }
        
        // Function to update the scroll view height constraint dynamically
        private func updateScrollViewHeight() {
            scrollViewHeightConstraint?.constant = scrollViewHeight
            layoutIfNeeded() // This will update the layout
        }

        // Function to set up images and video in the scroll view
        func setupScrollViewImages() {
            // Clear any existing images or video placeholders in the scroll view
            for subview in scrollView.subviews {
                subview.removeFromSuperview()
            }
            
            let imageHeight: CGFloat = scrollViewHeight
            let imageWidth: CGFloat = contentView.frame.width // Make image width the full width of the scroll view
            let padding: CGFloat = 10
            
            var xOffset: CGFloat = 0
            
            // Add video if available
            if let videoUrl = videoUrl, !videoUrl.isEmpty {
                let videoThumbnailView = UIImageView()
                videoThumbnailView.frame = CGRect(x: xOffset, y: 0, width: imageWidth, height: imageHeight)
                videoThumbnailView.contentMode = .scaleAspectFill
                videoThumbnailView.clipsToBounds = true
                videoThumbnailView.layer.cornerRadius = 8
                scrollView.addSubview(videoThumbnailView)
                
                // Generate thumbnail for video
                generateVideoThumbnail(from: videoUrl) { [weak self] thumbnail in
                    DispatchQueue.main.async {
                        videoThumbnailView.image = thumbnail
                    }
                }
                
                // Add a play button or video thumbnail overlay
                let playButton = UIButton(type: .custom)
                playButton.frame = CGRect(x: (imageWidth / 2) - 25, y: (imageHeight / 2) - 25, width: 50, height: 50)
                playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                playButton.tintColor = .white
                playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
                scrollView.addSubview(playButton)
                
                xOffset += imageWidth + padding
            }
            
            // Add images
            for imageUrl in images {
                let imageView = UIImageView()
                imageView.frame = CGRect(x: xOffset, y: 0, width: imageWidth, height: imageHeight)
                imageView.loadImage(from: imageUrl, placeholder: "logo") // Load image with placeholder "logo"
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = 8
                
                scrollView.addSubview(imageView)
                xOffset += imageWidth + padding
            }
            
            // Set content size of scroll view based on the number of images and video
            let contentWidth = xOffset
            scrollView.contentSize = CGSize(width: contentWidth, height: imageHeight)
        }
        
        // Generate thumbnail for video
        private func generateVideoThumbnail(from url: String, completion: @escaping (UIImage?) -> Void) {
            guard let videoURL = URL(string: url) else {
                completion(nil)
                return
            }
            
            let asset = AVAsset(url: videoURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            // Capture the first frame at time 1 second
            let time = CMTime(seconds: 1, preferredTimescale: 60)
            
            DispatchQueue.global().async {
                do {
                    let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    completion(thumbnail)
                } catch {
                    print("Error generating thumbnail: \(error)")
                    completion(nil)
                }
            }
        }
        
        // Play video action
        @objc func playVideo() {
            if let videoUrl = videoUrl, let url = URL(string: videoUrl) {
                let player = AVPlayer(url: url)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                
                if let topController = UIApplication.shared.windows.first?.rootViewController {
                    topController.present(playerViewController, animated: true) {
                        player.play()
                    }
                }
            }
        }
    

    
}

//MARK:- COLLECTION VIEW -
extension home: UICollectionViewDelegate ,
                     UICollectionViewDataSource ,
                     UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (self.userWhichIndex == "0") {
            return self.liveArray.count
        } else {
            let rowIndex = collectionView.tag
            return data[rowIndex].count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (self.userWhichIndex == "0") {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_collection_view_cell", for: indexPath as IndexPath) as! home_collection_view_cell

            cell.backgroundColor  = .clear
            
            let item = self.liveArray[indexPath.row] as? [String:Any]
            
            cell.lbl_username.text = (item!["userName"] as! String)
            cell.img_view.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.img_view.sd_setImage(with: URL(string: (item!["userImage"] as! String)), placeholderImage: UIImage(named: "1024"))
            
            cell.img_user.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.img_user.sd_setImage(with: URL(string: (item!["userImage"] as! String)), placeholderImage: UIImage(named: "1024"))
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "two2", for: indexPath as IndexPath) as! home_collection_view_cell2

            cell.backgroundColor  = .clear
            
            let rowIndex = collectionView.tag
            print(rowIndex as Any)
            print(data as Any)
            print(data[rowIndex] as Any)
            print(data[indexPath.item] as Any)
            // print(data[rowIndex] as Any)
            // print(data[indexPath.item] as Any)
            // cell.img_view.sd_setImage(with: URL(string: data[indexPath.row]), placeholderImage: UIImage(named: "1024"))
            /*let imageUrl = dataMutable[indexPath.item]
            print(imageUrl as Any)
            
            /*let last3 = (imageUrl as! String).suffix(3)
            print(last3)
            if (last3) == "mov" {
                
            } else if (last3) == "mp4" {
                
            } else {*/
                cell.img_view.sd_setImage(with: URL(string: imageUrl as! String), placeholderImage: UIImage(named: "1024"))
            // }
            
            cell.img_view.isUserInteractionEnabled = true
            cell.img_view.tag = indexPath.item
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            cell.img_view.addGestureRecognizer(tapGesture)*/
            
            return cell
            
        }
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView {
            ImageZoomHelper.presentZoomedImage(from: imageView, in: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (self.userWhichIndex == "0") {
            let item = self.liveArray[indexPath.row] as? [String:Any]
            
            let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "liveStreamingController_id") as? liveStreamingController
            
            push!.str_audience = "yes"
            push!.str_channel_name = (item!["channelName"] as! String)
            
            self.navigationController?.pushViewController(push!, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var sizes: CGSize
        let result = UIScreen.main.bounds.size
        NSLog("%f",result.height)
        if (self.userWhichIndex == "0") {
            sizes = CGSize(width: 140, height: 140)
        } else {
            sizes = CGSize(width: collectionView.frame.size.width, height: 370)
        }
        
        return sizes
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if (self.userWhichIndex == "0") {
            return 10
        } else {
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
         
        if (self.userWhichIndex == "0") {
            return 10
        } else {
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
 
        if (self.userWhichIndex == "0") {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
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
    
    @IBOutlet weak var lbl_live_text:UILabel! {
        didSet {
            lbl_live_text.backgroundColor = .systemOrange
            lbl_live_text.layer.cornerRadius = 10
            lbl_live_text.clipsToBounds = true
        }
    }
    
    
    @IBOutlet weak var img_user:UIImageView! {
        didSet {
            img_user.layer.cornerRadius = 10
            img_user.clipsToBounds = true
            img_user.backgroundColor = .brown
        }
    }
    
    @IBOutlet weak var lbl_username:UILabel! {
        didSet {
            lbl_username.backgroundColor = .clear
            lbl_username.textColor = .white
            lbl_username.layer.cornerRadius = 10
            lbl_username.clipsToBounds = true
        }
    }
    
}

class home_collection_view_cell2: UICollectionViewCell , UITextFieldDelegate {
    
    @IBOutlet weak var img_view:UIImageView! {
        didSet {
            img_view.layer.cornerRadius = 12
            img_view.clipsToBounds = true
            img_view.backgroundColor = .brown
        }
    }
    
    
    
}

// Extension to load images asynchronously with placeholder
extension UIImageView {
    func loadImage(from urlString: String, placeholder: String = "logo") {
        // Set placeholder image initially
        self.image = UIImage(named: placeholder)
        
        guard let url = URL(string: urlString) else { return }
        
        // Load the actual image asynchronously
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}


