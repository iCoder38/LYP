//
//  BooCheckChat.swift
//  BooCheck
//
//  Created by apple on 01/04/21.
//

import UIKit
import GrowingTextView
import Firebase
import FirebaseStorage
import SDWebImage
import Alamofire
// import MBProgressHUD

// sam //

class BooCheckChat: UIViewController, MessagingDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // ***************************************************************** // nav
        @IBOutlet weak var navigationBar:UIView!
        @IBOutlet weak var btnBack:UIButton!
        @IBOutlet weak var lblNavigationTitle:UILabel! {
            didSet {
                lblNavigationTitle.text = "CHAT"
               // lblNavigationTitle.textColor = NAVIGATION_TITLE_COLOR
            }
        }
    // ***************************************************************** // nav
    
    // let dict : [String : Any] = UserDefaults.standard.dictionary(forKey: "kAPI_LOGIN_DATA") ?? [:] //

    let cellReuseIdentifier = "cuckooChatCTableCell"
    
    // MARK:- mutable array set up -
    var chatMessages:NSMutableArray = []
    var dataDictionary:[String:Any] = [:]
    // var strLoginUserId:String!
    var strLoginUserName:String!
    var strLoginUserImage:String!
    
    var strReceiptId:String!
    var strReceiptImage:String!
    
    var imageStr1:String!
    var imgData1:Data!
    
    var uploadImageForChatURL:String!
    var chatChannelName:String!
    var receiverData:NSDictionary!
//    var receiverData : [String :Any] = [:]

    var strSaveLastMessage:String!
    
    var str_vendor_name:String!
    var str_vendor_id:String!
    var str_vendor_image:String!
    var str_vender_device_token:String!
    var str_vendor_device_name:String!
    
    var str_caller_name:String!
    var str_caller_id:String!
    var str_caller_image:String!
    var str_caller_device_token:String!
    var str_caller_device_name:String!
    
    var myDeviceTokenIs:String!
    
    
    
    @IBOutlet weak var uploadingImageView:UIView! {
        didSet {
          //  uploadingImageView.backgroundColor = APP_BASIC_COLOR
            uploadingImageView.isHidden = true
        }
    }
    
    @IBOutlet weak var indicators:UIActivityIndicatorView! {
        didSet {
            indicators.color = .white
        }
    }
    
    @IBOutlet weak var lblProcessingImage:UILabel! {
        didSet {
            lblProcessingImage.textColor = .white
            lblProcessingImage.text = "processing..."
        }
    }
    
    @IBOutlet weak var inputToolbar: UIView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgReceiverProfilePicture:UIImageView! {
        didSet {
            imgReceiverProfilePicture.layer.cornerRadius = 20
            imgReceiverProfilePicture.clipsToBounds = true
            imgReceiverProfilePicture.layer.borderWidth = 0.5
            imgReceiverProfilePicture.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    // MARK:- TABLE VIEW -
    @IBOutlet weak var tbleView: UITableView! {
        didSet {
            self.tbleView.delegate = self
            self.tbleView.dataSource = self
            self.tbleView.backgroundColor = .clear
            self.tbleView.tableFooterView = UIView.init(frame: CGRect(origin: .zero, size: .zero))
        }
    }
    
    @IBOutlet weak var btnSendMessage:UIButton! {
        didSet {
            btnSendMessage.tintColor = .white
        }
    }
    
    @IBOutlet weak var btnAttachment:UIButton! {
        didSet {
            btnAttachment.tintColor = .white
        }
    }

    @IBOutlet weak var btnPhone:UIButton!
    @IBOutlet weak var btnVideoCall:UIButton!
    
    var friendDeviceToken:String!
    
    // NEW FIRESTORE
    //
    var get_chat_data:NSDictionary!
    var str_login_user_id:String!
    var str_room_id:String!
    var str_reverse_room_id:String!
    var str_login_user_name:String!
    var str_login_user_image:String!
    var str_receiver_firebase_id:String!
    var str_receiver_firebase_name:String!
    var str_receiver_firebase_image:String!
    
    var chatListener: ListenerRegistration?
    var lastFetchedTimestamp: Timestamp?
    var lastFetchedTimestampMillis: Int64?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageStr1 = "0"
        self.uploadImageForChatURL = ""
        self.btnSendMessage.addTarget(self, action: #selector(sendMessageWithoutAttachment), for: .touchUpInside)
        // self.btnAttachment.addTarget(self, action: #selector(cellTappedMethod1), for: .touchUpInside)
        self.btnBack.addTarget(self, action: #selector(backClickMethod), for: .touchUpInside)
        // *** Customize GrowingTextView ***
        textView.layer.cornerRadius = 4.0
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = app_BG
        
        self.manage_and_parse()
        
    }
    
    @objc func manage_and_parse() {
        print(self.get_chat_data as Any)
        
        self.str_room_id = "\(self.get_chat_data["receverId"]!)+\(self.get_chat_data["senderId"]!)"
        self.str_reverse_room_id = "\(self.get_chat_data["senderId"]!)+\(self.get_chat_data["receverId"]!)"
        
        print(self.str_room_id as Any)
        print(self.str_reverse_room_id as Any)
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            print(person)
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            
            self.str_login_user_id = String(myString)
            self.str_login_user_name = (person["fullName"] as! String)
            self.str_login_user_image = (person["image"] as! String)
        }
        
        // manage counter
        // self.manage_notification_counter(dialogId: (self.get_chat_data["dialogId"] as! String))
        self.updateNotificationCount(matchingField: "dialogId", matchingValue: (self.get_chat_data["dialogId"] as! String))
        self.startListeningForChats(myID: self.str_room_id)
       
    }
    
    func updateNotificationCount(matchingField: String, matchingValue: String) {
        let db = Firestore.firestore()

        // Query the collection to find the document(s) with the specified matching field and value
        db.collection(COLLECTION_PATH_DIALOG)
            .whereField(matchingField, isEqualTo: matchingValue)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error querying documents: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No matching documents found.")
                    return
                }

                // Iterate over the found documents and update each one
                for document in documents {
                    let documentRef = document.reference

                    let data: [String: Any] = [
                        "usersUnreadNotification.\(self.str_login_user_id!)": 0
                    ]

                    // Update the document
                    documentRef.updateData(data) { error in
                        if let error = error {
                            print("Error updating document: \(error.localizedDescription)")
                        } else {
                            print("===========================")
                            print("Dialog updated successfully")
                            print("===========================")
                        }
                    }
                }
            }
    }
      
    func startListeningForChats(myID: String) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("mode/lyv/message/India/private_chats")
        
        // Remove any existing listener to avoid multiple listeners
        chatListener?.remove()
        
        // Create a query with a timestamp filter and order by timestamp
        var query: Query = collectionRef.whereField("users", arrayContains: myID)
            .order(by: "time_stamp", descending: false)
        
        if let lastTimestampMillis = lastFetchedTimestampMillis {
            // Filter documents where the timestamp (in milliseconds) is greater than the last fetched timestamp
            query = query.whereField("time_stamp", isGreaterThan: lastTimestampMillis)
        }
        
        // Set up a real-time listener
        chatListener = query.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            var dataArray: [[String: Any]] = []
            self.chatMessages.removeAllObjects()
            
            for document in querySnapshot!.documents {
                let data = document.data()
                dataArray.append(data)
                self.chatMessages.add(data)
            }
            
            // Update the last fetched timestamp with the latest document timestamp
            if let latestDocument = querySnapshot?.documents.last {
                self.lastFetchedTimestampMillis = latestDocument.data()["timestampMillis"] as? Int64
            }
            
            self.tbleView.reloadData()
        }
    }
       
    func stopListeningForChats() {
        chatListener?.remove()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            textViewBottomConstraint.constant = keyboardHeight + 8
            view.layoutIfNeeded()
        }
    }

    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    @objc func backClickMethod() {
        self.stopListeningForChats()
        self.navigationController?.popViewController(animated: true)
    }
    
    func manage_data_before_send_notification(get_type:String,getCallId:String) {
        
        print("============================")
        print(self.receiverData as Any)
        print("============================")
        
        let dict : [String : Any] = UserDefaults.standard.dictionary(forKey: "kAPI_LOGIN_DATA") ?? [:]
        print(dict as Any)
        
        self.str_vendor_name = (self.receiverData["userName"] as! String)
        self.str_vendor_id = "\(self.receiverData["userId"]!)"
        self.str_vendor_image = (self.receiverData["profile_picture"] as! String)
        self.str_vender_device_token = (self.receiverData["deviceToken"] as! String)
        self.str_vendor_device_name = (self.receiverData["device"] as! String)
         
         // caller
        self.str_caller_name = (dict["fullName"] as! String)
        self.str_caller_id = "\(dict["userId"]!)"
        self.str_caller_image = (dict["image"] as! String)
        self.str_caller_device_token = (dict["deviceToken"] as! String)
        self.str_caller_device_name = (dict["device"] as! String)
       
        print(get_type as Any)
        
        if (get_type == "audio") {
            // send notification
            // self.notificationWhenUserCallToSomeone(call_id: String(getCallId))
            
        } else {
            // notificationWhenUserCallToSomeoneForVideo(call_id: String(getCallId))
            // send notification
         
        }
        
        
        
    }
   
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.chatMessages.count-1, section: 0)
            self.tbleView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    @objc func convertSelectedImageFromGallery(img1 :UIImage) {
    }
    /*@objc func cellTappedMethod1(){
            // print("you tap image number: \(sender.view.tag)")
           let alert = UIAlertController(title: "Upload Profile Image", message: nil, preferredStyle: .actionSheet)
           alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
               print("User click Approve button")
               self.openCamera1()
           }))
           alert.addAction(UIAlertAction(title: "Gallery", style: .default , handler:{ (UIAlertAction)in
               print("User click Edit button")
               self.openGallery1()
           }))
           alert.addAction(UIAlertAction(title: "In-Appropriate terms", style: .default , handler:{ (UIAlertAction)in
               print("User click Delete button")
           }))
           alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
               print("User click Dismiss button")
           }))
           self.present(alert, animated: true, completion: {
               print("completion block")
           })
       }
       
       @objc func openCamera1() {
           let imagePicker = UIImagePickerController()
           imagePicker.delegate = self
           imagePicker.sourceType = .camera;
           imagePicker.allowsEditing = false
           self.present(imagePicker, animated: true, completion: nil)
       }
       
       @objc func openGallery1() {
           let imagePicker = UIImagePickerController()
           imagePicker.delegate = self
           imagePicker.sourceType = .photoLibrary;
           imagePicker.allowsEditing = false
           self.present(imagePicker, animated: true, completion: nil)
       }
       
       internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        self.uploadingImageView.isHidden = false
        self.indicators.startAnimating()
        var strURL = ""
        // Points to the root reference
        let store = Storage.storage()
        let storeRef = store.reference()
        // ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        // default
        let image_data = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let imageData:Data = image_data!.pngData()!
        imageStr1 = imageData.base64EncodedString()
        imgData1 = image_data!.jpegData(compressionQuality: 0.2)!
        // #2

        let storeImage = storeRef.child("singleChatImage").child(self.str_login_user_id+".png")
        // if let uploadImageData = UIImagePNGRepresentation((img.image)!){
        storeImage.putData(imgData1, metadata: nil, completion: { (metaData, error) in
            storeImage.downloadURL(completion: { (url, error) in
                        if let urlText = url?.absoluteString {
                            strURL = urlText
                            print("///////////tttttttt//////// \(strURL)   ////////")
                            self.uploadImageForChatURL = ("\(strURL)")
                            self.sendMessageWithAttachment()
                        }
                    })
                })
        self.imageStr1 = "1"
       }*/
    
    
    // MARK:- SEND IMAGE WITH ATTACHMENT -
    /*@objc func sendMessageWithAttachment() {
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.weekday,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let weekday = components.weekday
        
        let hourr = components.hour
        let minutee = components.minute
        
        let today_string = String(day!) + "/" + String(month!) + "/" + String(year!)
        
        let time_string = String(hourr!)+":"+String(minutee!)
        
        let ref = Database.database().reference().child("one_to_one").child(self.chatChannelName).childByAutoId()
        let message = ["attachment_path": (self.uploadImageForChatURL!),
                       "chatSenderId": String(self.self.str_login_user_id),
                       "chat_date": today_string,
                       "chat_message": String(self.textView.text!),
                       "chat_receiver": (receiverData["userName"] as! String),//String(self.strReceiptId),
                       "chat_receiver_img": String(self.strReceiptImage),
                       "chat_sender": String(self.strLoginUserName),
                       "chat_sender_img": String(self.strLoginUserImage),
                       "chat_time": time_string,
                       "type": String("image")] as [String : Any]
        ref.setValue(message)
        self.uploadingImageView.isHidden = true
    }*/
    
    func getCurrentTimestampInMilliseconds() -> Int64 {
        let currentDate = Date()
        let timestampInMilliseconds = Int64(currentDate.timeIntervalSince1970 * 1000)
        return timestampInMilliseconds
    }
    
    // MARK:- SEND IMAGE WITHOUT ATTACHMENT -
    @objc func sendMessageWithoutAttachment() {
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.weekday,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let weekday = components.weekday
        
        let hourr = components.hour
        let minutee = components.minute
        
        let today_string = String(day!) + "/" + String(month!) + "/" + String(year!)
        
        let time_string = String(hourr!)+":"+String(minutee!)
        
        if self.textView.text == "" {
        } else {
            
            let chatId = "yourChatId"
            let messageText = String(self.textView.text!)
            sendMessage(toChatId: chatId, messageText: messageText) { [self] error in
                if let error = error {
                    print("Error sending message: \(error)")
                } else {
                    print("Message sent successfully")
                    
                    let userId = String(self.str_room_id)
                    print(userId as Any)

                    let collectionPath = COLLECTION_PATH_DIALOG
                    let field = "dialogId"
                    let value = (self.get_chat_data["dialogId"] as! String)

                    checkIfDocumentExistsByField(collectionPath: collectionPath, field: field, value: value) { [self] exists, error in
                        if let error = error {
                            print("Failed to check document existence: \(error)")
                        } else if exists {
                            print("The document exists.")
                            
                            let timestamp = getCurrentTimestampInMilliseconds()
                            
                            let collectionPath = COLLECTION_PATH_DIALOG
                            let dialogId = (self.get_chat_data["dialogId"] as! String)
                            let dataToUpdate: [String: Any] = [
                                "message": messageText,
                                "time_stamp": timestamp,
                                "usersUnreadNotification.\(self.str_receiver_firebase_id!)": FieldValue.increment(Int64(1)),
                                "usersUnreadNotification.\(self.str_login_user_id!)": 0,
                                "sender_device"     : "iOS",
                                "sender_deviceToken": "",
                                "sender_name"       : String(self.str_login_user_name),
                                "sender_image"      : String(self.str_login_user_image)
                            ]

                            updateDocumentByDialogId(collectionPath: collectionPath, dialogId: dialogId, dataToUpdate: dataToUpdate) { error in
                                if let error = error {
                                    print("Failed to update document: \(error)")
                                } else {
                                    print("Document updated successfully.")
                                }
                            }
                            
                            
                        } else {
                            print("The document does not exist.")
                            
                            // create dialog if not there
                            self.add_or_create_dialog(messageText: messageText){
                                error in
                                if let error = error {
                                    print("Error sending message: \(error)")
                                } else {
                                    print("Dialog created successfully")
                                }
                                
                            }
                             
                            
                        }
                    }
                }
            }
        }
    }
    
    func updateDocumentByDialogId(collectionPath: String, dialogId: String, dataToUpdate: [String: Any], completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let collectionRef = db.collection(collectionPath)
        
        // Query to find the document where 'dialogId' is equal to the given value
        collectionRef.whereField("dialogId", isEqualTo: dialogId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(error)
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                print("Document with dialogId \(dialogId) not found.")
                completion(nil)
                return
            }
            
            // Update the found document
            document.reference.updateData(dataToUpdate) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                    completion(error)
                } else {
                    print("Document successfully updated.")
                    completion(nil)
                }
            }
        }
    }
    
    func add_or_create_dialog(messageText: String, completion: @escaping (Error?) -> Void) {
        self.textView.text = ""
        let db = Firestore.firestore()
        let messagesRef = db.collection(COLLECTION_PATH_DIALOG)

        let randomString = generateRandomAlphanumericString(length: 10)
        
        let timestamp = getCurrentTimestampInMilliseconds()
        
        // Create a dictionary with message data
        let messageData: [String: Any] = [
            "dialogId":randomString,
            "members"         : [
                String(self.str_login_user_id),
                String(self.str_receiver_firebase_id)
            ],
            "message":messageText,
            "receiver_image":String(str_receiver_firebase_image),
            "receiver_name":String(str_receiver_firebase_name),
            "receverId":String(str_receiver_firebase_id),
            "receiver_device": "iOS",
            "receiver_device_token":"",
            "senderId": String(self.str_login_user_id),
            "sender_device":"iOS",
            "sender_deviceToken":"",
            "sender_image":String(self.str_login_user_image),
            "sender_name":String(self.str_login_user_name),
            "time_stamp":timestamp,
            "type":"Text",
            "users":[self.str_room_id,self.str_reverse_room_id]
            
        ]

        // Add a new document with a generated ID
        messagesRef.addDocument(data: messageData) { error in
            if let error = error {
                print("Error adding message: \(error)")
                completion(error)
            } else {
                print("DIALOG added successfully")
                completion(nil)
            }
        }
    }
    
    func sendMessage(toChatId chatId: String, messageText: String, completion: @escaping (Error?) -> Void) {
        self.textView.text = ""
        let db = Firestore.firestore()
        let messagesRef = db.collection("mode/lyv/message/India/private_chats")

        let timestamp = getCurrentTimestampInMilliseconds()
        
        // Create a dictionary with message data
        let messageData: [String: Any] = [
            "message"       : messageText,
            "timestamp2"    : FieldValue.serverTimestamp(),
            "time_stamp"    : timestamp,
            "receiver_firebase_id": String(self.str_receiver_firebase_id),
            "room"          : "private",
            "room_id"       : String(self.str_room_id),
            "sender_firebase_id"    : String(self.str_login_user_id),
            "sender_image"  : String(self.str_login_user_image),
            "sender_name"   : String(self.str_login_user_name),
            "type"          : "Text",
            "users"         : [
                self.str_room_id,
                self.str_reverse_room_id
            ],
            
            "usersUnreadNotification": [
                self.str_receiver_firebase_id: FieldValue.increment(Int64(1)),
                self.str_login_user_id: 0
                    ]
            
        ]

        // Add a new document with a generated ID
        messagesRef.addDocument(data: messageData) { error in
            if let error = error {
                print("Error adding message: \(error)")
                completion(error)
            } else {
                print("Message added successfully")
                completion(nil)
            }
        }
    }
    
    func checkIfDocumentExistsByField(collectionPath: String, field: String, value: Any, completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        let collectionRef = db.collection(collectionPath)
        
        // Query to find documents where the specified field matches the given value
        collectionRef.whereField(field, isEqualTo: value).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(false, error)
                return
            }
            
            // Check if any documents match the criteria
            let exists = !querySnapshot!.documents.isEmpty
            
            completion(exists, nil)
        }
    }
    
}

extension BooCheckChat: GrowingTextViewDelegate {
    // *** Call layoutIfNeeded on superview for animation when changing height ***
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension BooCheckChat: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatMessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.chatMessages[indexPath.row] as? [String:Any]
        if item!["sender_firebase_id"] as! String == String(self.str_login_user_id) {
            if item!["type"] as! String == "Text" {
                
                // text
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "cellOne") as! BooCheckTableCell
                cell1.senderName.text = (item!["sender_name"] as! String)
                cell1.senderText.text = (item!["message"] as! String)
                cell1.backgroundColor = .clear
                cell1.imgSender.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                cell1.imgSender.sd_setImage(with: URL(string:String(self.str_login_user_image)), placeholderImage: UIImage(named: "logo_300"))
                return cell1
                
            } else  {
                
                // image
                let cell3 = tableView.dequeueReusableCell(withIdentifier: "cellThree") as! BooCheckTableCell
                cell3.imgSenderAttachment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                cell3.imgSenderAttachment.sd_setImage(with: URL(string: (item!["attachment_path"] as! String)), placeholderImage: UIImage(named: "logo_300"))
                cell3.backgroundColor = .clear
                cell3.imgSenderAttachment2.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                cell3.imgSenderAttachment2.sd_setImage(with: URL(string: (item!["sender_image"] as! String)), placeholderImage: UIImage(named: "logo_300"))
                return cell3
                
            }
        } else { // receiver txt
            if item!["type"] as! String == "Text" {
                
                let cell2 = tableView.dequeueReusableCell(withIdentifier: "cellTwo") as! BooCheckTableCell
                 cell2.receiverName.text = "receiver name"//(receiverData["sender_name"] as! String)// (item!["chat_receiver"] as! String)
                 cell2.receiverText.text = (item!["message"] as! String)
                 cell2.backgroundColor = .clear
                cell2.imgReceiver.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                cell2.imgReceiver.sd_setImage(with: URL(string: self.str_receiver_firebase_image), placeholderImage: UIImage(named: "logo_300"))
                return cell2
                
            } else { // receiver image
                
                let cell4 = tableView.dequeueReusableCell(withIdentifier: "cellFour") as! BooCheckTableCell
                cell4.imgReceiverAttachment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                cell4.imgReceiverAttachment.sd_setImage(with: URL(string: (item!["attachment_path"] as! String)), placeholderImage: UIImage(named: "logo_300"))
                cell4.backgroundColor = .clear
                cell4.imgReceiverAttachment2.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                cell4.imgReceiverAttachment2.sd_setImage(with: URL(string: self.str_receiver_firebase_image), placeholderImage: UIImage(named: "logo_300"))
                return cell4
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.chatMessages[indexPath.row] as? [String:Any]
        if item!["type"] as! String == "Text" {
            return UITableView.automaticDimension
        } else {
            return 240
        }
    }
}

extension BooCheckChat: UITableViewDelegate {
}

struct SendLastMessageToServerWB: Encodable {
    let action: String
    let senderId: String
    let receiverId: String
    let message: String
}

struct ReadUnreadStatus: Encodable {
    let action: String
    let senderId: String
    let receiverId: String
}

