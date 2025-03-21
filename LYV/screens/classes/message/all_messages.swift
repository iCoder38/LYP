//
//  all_messages.swift
//  LYV
//
//  Created by Dishant Rajput on 08/08/24.
//

import UIKit
import Alamofire
import SDWebImage
import  Firebase

class all_messages: UIViewController {
    
    var arr_category:NSMutableArray! = []
    var chatArray: NSMutableArray = []
    var str_login_user_id:String!
    
    @IBOutlet weak var btn_add:UIButton!
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
    
    var listener: ListenerRegistration?
    
    @IBOutlet weak var collectionView1:UICollectionView! {
        didSet {
            collectionView1.isPagingEnabled = false
            collectionView1.backgroundColor = .clear
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = app_BG
        
        self.btn_add.addTarget(self, action: #selector(add_user_chat), for: .touchUpInside)
        
        callFriendListWB(loader: "yes")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            print(person)
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            let myID = String(myString)
            self.str_login_user_id = myID
            
            fetchFilteredData(myID: myID) { (dataArray, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let dataArray = dataArray {
                    print("Fetched data: \(dataArray)")
                    
                    self.tble_view.reloadData()
                }
            }
        }
        
    }
    
    @objc func callFriendListWB(loader:String) {
        
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
                    "action"    : "frinedlist",
                    "userId"    : String(myString),
                    "status"      : String("2")
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
                                
                                // for table
                                self.tble_view.delegate = self
                                self.tble_view.dataSource = self
                                self.tble_view.reloadData()
                                
                                // for collection
                                self.arr_category.removeAllObjects()
                                self.arr_category.addObjects(from: ar as! [Any])
                                self.collectionView1.delegate = self
                                self.collectionView1.dataSource = self
                                self.collectionView1.reloadData()
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.callFriendListWB(loader: "no")
                                        
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
                        
                        self.callFriendListWB(loader: "no")
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
    
    func fetchFilteredData(myID: String, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        let db = Firestore.firestore()
        let collectionRef = db.collection(COLLECTION_PATH_DIALOG)
        
        let listener = collectionRef
            .whereField("members", arrayContains: myID)
            .order(by: "time_stamp", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion(nil, error)
                    return
                }
                
                var dataArray: [[String: Any]] = []
                self.chatArray.removeAllObjects()
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    dataArray.append(data)
                    self.chatArray.add(data)
                }
                
                // Reload the table view with the sorted data
                DispatchQueue.main.async {
                    self.tble_view.delegate = self
                    self.tble_view.dataSource = self
                    self.tble_view.reloadData()
                }
                
                completion(dataArray, nil)
            }
        
        self.listener = listener
    }
    
    @objc func add_user_chat() {
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "all_users_id") as? all_users
        self.navigationController?.pushViewController(push!, animated: true)
    }
    
}

//MARK:- TABLE VIEW -
extension all_messages: UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:all_messages_table_cell = tableView.dequeueReusableCell(withIdentifier: "all_messages_table_cell") as! all_messages_table_cell
        
        cell.backgroundColor = .clear
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
        
        let item = self.chatArray[indexPath.row] as? [String:Any]
        // print(item as Any)
        // print(item!["usersUnreadNotification"] as Any)
        // print(type(of: item!["usersUnreadNotification"]))
        if "\(item!["senderId"]!)" == self.str_login_user_id {
            // login user
            cell.lbl_name.text = "\(item!["receiver_name"]!)"
            cell.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.img_profile.sd_setImage(with: URL(string: (item!["receiver_image"] as! String)), placeholderImage: UIImage(named: "1024"))
        } else {
            // receiver
            cell.lbl_name.text = "\(item!["sender_name"]!)"
            cell.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.img_profile.sd_setImage(with: URL(string: (item!["sender_image"] as! String)), placeholderImage: UIImage(named: "1024"))
        }
        
        cell.lbl_message.text = "\(item!["message"]!)"
        
        // cell.lbl_notification_counter.text =
        
        return cell
        
    }
    
    func extractKey(from data: [[String: Any]], keyToFind: String) -> Int? {
        guard let firstItem = data.first else {
            print("No data available.")
            return nil
        }
        
        // Access the nested dictionary
        if let usersUnreadNotification = firstItem["usersUnreadNotification"] as? [String: Any] {
            // Check if the key exists in the dictionary
            if let value = usersUnreadNotification[keyToFind] as? Int {
                return value
            } else {
                print("Key \(keyToFind) not found.")
                return nil
            }
        } else {
            print("usersUnreadNotification key not found in dictionary.")
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.chatArray[indexPath.row] as? [String:Any]
        print(item as Any)
        
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BooCheckChat") as? BooCheckChat
        push!.get_chat_data = item! as NSDictionary
        push!.str_from_dialog = "yes"
        if "\(item!["senderId"]!)" == self.str_login_user_id {
            // login user
            push!.str_receiver_firebase_id = "\(item!["receverId"]!)"
            push!.str_receiver_firebase_name = "\(item!["receiver_name"]!)"
            push!.str_receiver_firebase_image = "\(item!["receiver_image"]!)"
        } else {
            // receiver
            push!.str_receiver_firebase_id = "\(item!["senderId"]!)"
            push!.str_receiver_firebase_name = "\(item!["sender_name"]!)"
            push!.str_receiver_firebase_image = "\(item!["sender_image"]!)"
        }
        self.navigationController?.pushViewController(push!, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

class all_messages_table_cell : UITableViewCell {
    
    @IBOutlet weak var img_profile:UIImageView! {
        didSet {
            img_profile.layer.cornerRadius = 25
            img_profile.clipsToBounds = true
            img_profile.backgroundColor = .white
        }
    }
    
    
    @IBOutlet weak var lbl_name:UILabel! {
        didSet {
            lbl_name.textColor = .white
        }
    }
    
    @IBOutlet weak var lbl_message:UILabel! {
        didSet {
            lbl_message.textColor = .systemGray3
        }
    }
    
    @IBOutlet weak var lbl_notification_counter:UILabel! {
        didSet {
            lbl_notification_counter.textColor = .white
        }
    }
    
}



//MARK:- COLLECTION VIEW -
extension all_messages: UICollectionViewDelegate ,
                     UICollectionViewDataSource ,
                        UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return self.arr_category.count
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "all_messages_view_cell", for: indexPath as IndexPath) as! all_messages_view_cell
        
        let item = self.arr_category[indexPath.row] as? [String:Any]
        
        print(item as Any)
        
        cell.lbl_title.text = (item!["sender_userName"] as! String)
        cell.lbl_title.textColor = .white
        
        cell.img_profile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.img_profile.sd_setImage(with: URL(string: (item!["sender_profile_picture"] as! String)), placeholderImage: UIImage(named: "1024"))
        
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = self.arr_category[indexPath.row] as? [String:Any]
        print(item as Any)
        
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BooCheckChat") as? BooCheckChat
        push!.get_chat_data = item! as NSDictionary
        push!.str_from_dialog = "yes"
        if "\(item!["senderId"]!)" == self.str_login_user_id {
            // login user
            push!.str_receiver_firebase_id = "\(item!["receverId"]!)"
            push!.str_receiver_firebase_name = "\(item!["receiver_name"]!)"
            push!.str_receiver_firebase_image = "\(item!["receiver_image"]!)"
        } else {
            // receiver
            push!.str_receiver_firebase_id = "\(item!["senderId"]!)"
            push!.str_receiver_firebase_name = "\(item!["sender_name"]!)"
            push!.str_receiver_firebase_image = "\(item!["sender_image"]!)"
        }
        self.navigationController?.pushViewController(push!, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        var sizes: CGSize
        let result = UIScreen.main.bounds.size
        NSLog("%f",result.height)
        sizes = CGSize(width: 90, height: 70)
        
        return sizes
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    }
    
}

class all_messages_view_cell: UICollectionViewCell , UITextFieldDelegate {
    
    @IBOutlet weak var lbl_title:UILabel!
    
    @IBOutlet weak var img_profile:UIImageView! {
        didSet {
            img_profile.layer.cornerRadius = 25
            img_profile.clipsToBounds = true
            img_profile.backgroundColor = .white
        }
    }
}
