//
//  Utils.swift
//  LinkedDoc
//
//  Created by Dishant Rajput on 11/03/24.
//

import UIKit
import Foundation


let application_base_url = "https://demo4.evirtualservices.net/lyvapp/services/index"

let str_save_login_user_data = "keyLoginFullData"
let str_save_last_api_token = "key_last_api_token"

let your_are_not_auth = "You are not authorize to access the API"

var default_key_language = "key_select_language"
var english_language = "en"
var chinese_language = "ch"
var spanish_language = "sp"

// COLORS
var app_purple_color = UIColor.init(red: 118.0/255.0, green: 104.0/255.0, blue: 172.0/255.0, alpha: 1)
var app_BG = UIColor.init(red: 37.0/255.0, green: 42.0/255.0, blue: 55.0/255.0, alpha: 1)


// Step 1: Define the color dictionary
let colorDictionary: [String: String] = [
    "1": "Red",
    "2": "Green",
    "3": "Yellow",
    "4": "Blue",
    "5": "Sky-Blue",
    "6": "Brown",
    "7": "Pink",
    "8": "Purple",
    "9": "Magenta",
    "10": "Orange",
    "11": "White"
]

// Step 2: Define the reusable method to get color names
func getColorNames(from colorCodes: String) -> [String] {
    let codes = colorCodes.split(separator: ",")
    var colorNames: [String] = []
    
    for code in codes {
        if let colorName = colorDictionary[String(code)] {
            colorNames.append(colorName)
        }
    }
    
    return colorNames
}


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
    
    
    @objc func please_check_your_internet_connection() {
        let alert = NewYorkAlertController(title: String("Error").uppercased(), message: String("Please check your Internet Connection"), style: .alert)
        let cancel = NewYorkButton(title: "dismiss", style: .cancel)
        alert.addButtons([cancel])
        self.present(alert, animated: true)
    }
    
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
