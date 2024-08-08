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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = app_BG
        
        self.btn_add.addTarget(self, action: #selector(add_user_chat), for: .touchUpInside)
        
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
    
    /*func fetchFilteredData(myID: String, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        let db = Firestore.firestore()
        let collectionRef = db.collection(COLLECTION_PATH_DIALOG)
        
        
        collectionRef
            .whereField("members", arrayContains: myID)
            .order(by: "time_stamp", descending: true) // Sort by timestamp, latest first
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion(nil, error)
                } else {
                    var dataArray: [[String: Any]] = []
                    self.chatArray.removeAllObjects() // Clear the current chat array
                    
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        dataArray.append(data) // Add the data to the array
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
            }
    }*/

    @objc func add_user_chat() {
        
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
        print(item as Any)
        print(item!["usersUnreadNotification"] as Any)
        print(type(of: item!["usersUnreadNotification"]))
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
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BooCheckChat") as? BooCheckChat
        push!.get_chat_data = item! as NSDictionary
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
