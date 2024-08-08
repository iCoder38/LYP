//
//  add_post.swift
//  LYV
//
//  Created by Dishant Rajput on 08/08/24.
//

import UIKit
import Alamofire
import SDWebImage
import AVFoundation
import AVKit

class add_post: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var str_user_select_image:String! = "0"
    var img_data_banner : Data!
    var img_Str_banner : String!
    
    var videoURL : NSURL?
    var str_select_video:String! = "0"
    
    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.tintColor = .white
            btn_back.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var txt_view:UITextView! {
        didSet {
            txt_view.layer.cornerRadius = 12
            txt_view.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var btn_add_photo:UIButton! {
        didSet {
            btn_add_photo.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBOutlet weak var btn_add_video:UIButton!  {
        didSet {
            btn_add_video.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBOutlet weak var btn_add_post:UIButton! {
        didSet {
            btn_add_post.backgroundColor = .white
            btn_add_post.layer.cornerRadius = 25
            btn_add_post.clipsToBounds = true
            btn_add_post.setTitle("Add Post", for: .normal)
            btn_add_post.backgroundColor = app_purple_color
        }
    }
    
    @IBOutlet weak var img_photo1:UIImageView! {
        didSet {
            img_photo1.isHidden = true
        }
    }
    
    @IBOutlet weak var img_video1:UIImageView! {
        didSet {
            img_video1.isHidden = true
        }
    }
    @IBOutlet weak var btn_play:UIButton! {
        didSet {
            btn_play.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = app_BG
        
        self.btn_add_photo.addTarget(self, action: #selector(only_photo_c), for: .touchUpInside)
        self.btn_add_video.addTarget(self, action: #selector(only_video_c), for: .touchUpInside)
        
        self.btn_add_post.addTarget(self, action: #selector(add_post_only_title_WB), for: .touchUpInside)
        
    }
    
    @objc func only_photo_c() {
        self.str_select_video = "1"
        self.open_camera_gallery()
    }
    
    @objc func only_video_c() {
        self.str_select_video = "2"
        self.open_camera_gallery()
    }
    
    
    // MARK: - OPEN CAMERA OR GALLERY -
    @objc func open_camera_gallery() {
        
        if (self.str_select_video == "2") {
            
            let actionSheet = NewYorkAlertController(title: "Upload video", message: nil, style: .actionSheet)
            
            let gallery = NewYorkButton(title: "Gallery", style: .default) { _ in
                self.open_camera_or_gallery(str_type: "g")
            }
            let cancel = NewYorkButton(title: "Cancel", style: .cancel)
            actionSheet.addButtons([gallery, cancel])
            
            self.present(actionSheet, animated: true)
            
        } else {
            let actionSheet = NewYorkAlertController(title: "Upload pics", message: nil, style: .actionSheet)
            
            // actionSheet.addImage(UIImage(named: "camera"))
            
            let cameraa = NewYorkButton(title: "Camera", style: .default) { _ in
                // print("camera clicked done")
                
                self.open_camera_or_gallery(str_type: "c")
            }
            
            let gallery = NewYorkButton(title: "Gallery", style: .default) { _ in
                // print("camera clicked done")
                
                self.open_camera_or_gallery(str_type: "g")
            }
            
            let cancel = NewYorkButton(title: "Cancel", style: .cancel)
            
            actionSheet.addButtons([cameraa, gallery, cancel])
            
            self.present(actionSheet, animated: true)
        }
        
        
    }
    
    // MARK: - OPEN CAMERA or GALLERY -
    @objc func open_camera_or_gallery(str_type:String) {
        
        if (self.str_select_video == "2") {
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.movie"]
            present(imagePicker, animated: true, completion: nil)
            
        } else {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
            if str_type == "c" {
                imagePicker.sourceType = .camera
            } else {
                imagePicker.sourceType = .photoLibrary
            }
            
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if (self.str_select_video == "2") {
            // self.str_user_select_image = "2"
            self.img_video1.isHidden = false
            videoURL = info[UIImagePickerController.InfoKey.mediaURL]as? NSURL
            print(videoURL!)
            do {
                let asset = AVURLAsset(url: videoURL! as URL , options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                img_video1.image = thumbnail
                self.btn_play.isHidden = false
                self.btn_play.addTarget(self
                                        , action: #selector(play_uploaded_video), for: .touchUpInside)
            } catch let error {
                print("*** Error generating thumbnail: \(error.localizedDescription)")
            }
            self.dismiss(animated: true, completion: nil)
            
        } else {
            let image_data = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            
            self.img_photo1.isHidden = false
            self.img_photo1.image = image_data
            let imageData:Data = image_data!.pngData()!
            self.img_Str_banner = imageData.base64EncodedString()
            self.dismiss(animated: true, completion: nil)
            self.img_data_banner = image_data!.jpegData(compressionQuality: 0.2)!
            self.dismiss(animated: true, completion: nil)
            
            self.str_user_select_image = "1"
        }
        
    }
    
    @objc func play_uploaded_video() {
        let player = AVPlayer(url: videoURL! as URL)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true) {
            player.play()
            
        }
    }
    
    // only text
    @objc func add_post_only_title_WB() {
        
        if (self.str_user_select_image == "1") {
            self.validation_before_upload()
            
            return
        }
        
        if (self.str_select_video == "2") {
            self.validation_before_upload()
           
            return
        }
        
        if (self.txt_view.text == "") {
            return
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
                    "action"    : "postadd",
                    "userId"    : String(myString),
                    "title"     : String(self.txt_view.text!),
                    
                ]
                
                print("parameters-------\(String(describing: parameters))")
                
                AF.request(application_base_url, method: .post, parameters: parameters as? Parameters,headers: headers).responseJSON {
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
                                self.navigationController?.popViewController(animated: true)
                                
                            }
                            else {
                                self.refresh_token_WB3()
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
                self.refresh_token_WB3()
            }
        }
        
    }
    
    @objc func refresh_token_WB3() {
        
        var parameters:Dictionary<AnyHashable, Any>!
        
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            
            parameters = [
                "action"    : "gettoken",
                "userId"    : String(myString),
                "email"     : (person["email"] as! String),
                "role"      : "Member"
            ]
        }
        
        print("parameters-------\(String(describing: parameters))")
        
        AF.request(application_base_url, method: .post, parameters: parameters as? Parameters).responseJSON {
            response in
            
            switch(response.result) {
            case .success(_):
                if let data = response.value {
                    
                    let JSON = data as! NSDictionary
                    print(JSON)
                    
                    var strSuccess : String!
                    strSuccess = JSON["status"] as? String
                    
                    if strSuccess.lowercased() == "success" {
                        
                        let str_token = (JSON["AuthToken"] as! String)
                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                        
                        self.add_post_only_title_WB()
                        
                    } else {
                        ERProgressHud.sharedInstance.hide()
                    }
                    
                }
                
            case .failure(_):
                print("Error message:\(String(describing: response.error))")
                ERProgressHud.sharedInstance.hide()
                self.please_check_your_internet_connection()
                
                break
            }
        }
    }
    
    
    
    
    
    @objc func upload_profile_image_WB() {
        
        ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            if let token_id_is = UserDefaults.standard.string(forKey: str_save_last_api_token) {
                
                //            let headers: HTTPHeaders = [
                //                "token":String(token_id_is),
                //            ]
                //Set Your URL
                let api_url = application_base_url
                guard let url = URL(string: api_url) else {
                    return
                }
                
                var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
                urlRequest.httpMethod = "POST"
                urlRequest.allHTTPHeaderFields = ["token":String(token_id_is)]
                urlRequest.addValue("application/json",
                                    forHTTPHeaderField: "Accept")
                
                //urlRequest.addValue("Bearer \(token_id_is)", forHTTPHeaderField: "Authorization")
                
                //Set Your Parameter
                let parameterDict = NSMutableDictionary()
                
                // car information
                parameterDict.setValue("postadd", forKey: "action")
                parameterDict.setValue(String(myString), forKey: "userId")
                parameterDict.setValue(String(self.txt_view.text!), forKey: "title")
                
                print(parameterDict as Any)
                
                // Now Execute
                AF.upload(multipartFormData: { multiPart in
                    for (key, value) in parameterDict {
                        if let temp = value as? String {
                            multiPart.append(temp.data(using: .utf8)!, withName: key as! String)
                        }
                        if let temp = value as? Int {
                            multiPart.append("\(temp)".data(using: .utf8)!, withName: key as! String)
                        }
                        if let temp = value as? NSArray {
                            temp.forEach({ element in
                                let keyObj = key as! String + "[]"
                                if let string = element as? String {
                                    multiPart.append(string.data(using: .utf8)!, withName: keyObj)
                                } else
                                if let num = element as? Int {
                                    let value = "\(num)"
                                    multiPart.append(value.data(using: .utf8)!, withName: keyObj)
                                }
                            })
                        }
                    }
                    multiPart.append(self.img_data_banner, withName: "image_1", fileName: "add_post.png", mimeType: "image/png")
                }, with: urlRequest)
                .uploadProgress(queue: .main, closure: { progress in
                    //Current upload progress of file
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                .responseJSON(completionHandler: { data in
                    
                    switch data.result {
                        
                    case .success(_):
                        do {
                            
                            let dictionary = try JSONSerialization.jsonObject(with: data.data!, options: .fragmentsAllowed) as! NSDictionary
                            print(dictionary)
                            
                            var message : String!
                            message = (dictionary["msg"] as? String)
                            
                            if (dictionary["status"] as! String) == "success" {
                                print("yes")
                                
                                    ERProgressHud.sharedInstance.hide()
                                    self.navigationController?.popViewController(animated: true)
                               
                                
                                
                            } else if (dictionary["status"] as! String) == "Success" {
                                print("yes")
                                
                                if (self.str_user_select_image == "2") {
                                    
                                    if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
                                        
                                        let x : Int = person["userId"] as! Int
                                        let myString = String(x)

                                        if let token_id_is = UserDefaults.standard.string(forKey: str_save_last_api_token) {
                                            let parameters: [String: String] = [
                                                "action": "postadd",
                                                    "userId": String(myString),
                                                    "title": String(self.txt_view.text!)
                                                ]
                                                
                                                let token = token_id_is
                                                
                                            self.uploadVideo(fileURL: self.videoURL! as URL, to: application_base_url, parameters: parameters, token: token)
                                        }
                                    }
                                    
                                    return
                                } else {
                                    ERProgressHud.sharedInstance.hide()
                                    self.navigationController?.popViewController(animated: true)
                                }
                                
                            } else {
                                ERProgressHud.sharedInstance.hide()
                                self.refresh_token_WB4()
                                
                            }
                            
                        } catch {
                            // catch error.
                            print("catch error")
                            ERProgressHud.sharedInstance.hide()
                        }
                        break
                        
                    case .failure(_):
                        print("failure")
                        ERProgressHud.sharedInstance.hide()
                        break
                        
                    }
                    
                })
            }
        }
    }
    
    @objc func refresh_token_WB4() {
        
        var parameters:Dictionary<AnyHashable, Any>!
        
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            
            parameters = [
                "action"    : "gettoken",
                "userId"    : String(myString),
                "email"     : (person["email"] as! String),
                "role"      : "Member"
            ]
        }
        
        print("parameters-------\(String(describing: parameters))")
        
        AF.request(application_base_url, method: .post, parameters: parameters as? Parameters).responseJSON {
            response in
            
            switch(response.result) {
            case .success(_):
                if let data = response.value {
                    
                    let JSON = data as! NSDictionary
                    print(JSON)
                    
                    var strSuccess : String!
                    strSuccess = JSON["status"] as? String
                    
                    if strSuccess.lowercased() == "success" {
                        
                        let str_token = (JSON["AuthToken"] as! String)
                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                        
                        self.upload_profile_image_WB()
                        
                    } else {
                        ERProgressHud.sharedInstance.hide()
                    }
                    
                }
                
            case .failure(_):
                print("Error message:\(String(describing: response.error))")
                ERProgressHud.sharedInstance.hide()
                self.please_check_your_internet_connection()
                
                break
            }
        }
    }
    
    
   
    
    
    @objc func validation_before_upload() {
        
        if (self.str_user_select_image == "1" && self.str_select_video == "2") {
            // both image and video
           
            if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
                
                let x : Int = person["userId"] as! Int
                let myString = String(x)
                
                if let token_id_is = UserDefaults.standard.string(forKey: str_save_last_api_token) {
                    let parameters: [String: String] = [
                        "action": "postadd",
                        "userId": String(myString),
                        "title": String(self.txt_view.text!)
                    ]
                    
                    let token = token_id_is
                    ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
                    uploadImageAndVideo(videoURL: videoURL! as URL, to: application_base_url, parameters: parameters, token: token)
                }
            }
                
            
             

        } else if (self.str_select_video == "2") {
            if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
                
                let x : Int = person["userId"] as! Int
                let myString = String(x)

                if let token_id_is = UserDefaults.standard.string(forKey: str_save_last_api_token) {
                    let parameters: [String: String] = [
                        "action": "postadd",
                            "userId": String(myString),
                            "title": String(self.txt_view.text!)
                        ]
                        
                        let token = token_id_is
                    ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
                    uploadVideo(fileURL: videoURL! as URL, to: application_base_url, parameters: parameters, token: token)
                }
            }
        }
        
        else {
            self.upload_profile_image_WB()
        }
        
        
    }
    
    func uploadVideo(fileURL: URL, to urlString: String, parameters: [String: String], token: String) {
        
        let headers: HTTPHeaders = [
            "token": token,
            "Accept": "application/json",
            "Content-type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            // Append the video file
            multipartFormData.append(fileURL, withName: "video", fileName: "video.mp4", mimeType: "video/mp4")
            
            // Append additional parameters
            for (key, value) in parameters {
                if let data = value.data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
        }, to: urlString, headers: headers)
        .uploadProgress { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        .response { response in
            switch response.result {
            case .success:
                print("Video upload successful!")
                
                ERProgressHud.sharedInstance.hide()
                self.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                print("Video upload failed with error: \(error)")
            }
        }
    }
    
    func uploadImageAndVideo(videoURL: URL, to urlString: String, parameters: [String: String], token: String) {
        let headers: HTTPHeaders = [
            "token": token,
            "Accept": "application/json",
            "Content-type": "multipart/form-data"
        ]
        
        
        AF.upload(multipartFormData: { multipartFormData in
            // Append the image data
            multipartFormData.append(self.img_data_banner, withName: "image_1", fileName: "image.jpg", mimeType: "image/jpeg")
            
            // Append the video file
            multipartFormData.append(videoURL, withName: "video", fileName: "video.mp4", mimeType: "video/mp4")
            
            // Append additional parameters
            for (key, value) in parameters {
                if let data = value.data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
        }, to: urlString, headers: headers)
        .uploadProgress { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        .response { response in
            switch response.result {
            case .success:
                print("Image and Video upload successful!")
                
                ERProgressHud.sharedInstance.hide()
                self.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                print("Upload failed with error: \(error)")
            }
        }
    }

}
