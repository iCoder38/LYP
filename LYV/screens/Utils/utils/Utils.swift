//
//  Utils.swift
//  LinkedDoc
//
//  Created by Dishant Rajput on 11/03/24.
//

import UIKit

let str_save_login_user_data = "keyLoginFullData"
let str_save_last_api_token = "key_last_api_token"

let your_are_not_auth = "You are not authorize to access the API"

var default_key_language = "key_select_language"
var english_language = "en"
var chinese_language = "ch"
var spanish_language = "sp"

// COLORS
var app_purple_color = UIColor.init(red: 118.0/255.0, green: 104.0/255.0, blue: 172.0/255.0, alpha: 1)


class Utils: NSObject {

     
    class func light_vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    class func medium_vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    class func heavy_vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
}

extension UIViewController {
    
    @objc  func back_click_method() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
