//
//  Utils.swift
//  LinkedDoc
//
//  Created by Dishant Rajput on 11/03/24.
//

import UIKit
import Foundation


let application_base_url = "https://demo4.evirtualservices.net/lyvapp/services/index"

let AGORA_APP_ID = "dd002b2584734a9f9ad23da29f08c69f"
let AGORA_PRIMARY_CERTIFICATE_KEY = "e6da09477b5e4b1f998edbb7457726df"
let AGORA_TEMP_TOKEN = "007eJxTYJi4REm+6H968kKPJn73jikpC766/XsXlqz4c7PS1oCC/RoKDCkpBgZGSUamFibmxiaJlmmWiSlGximJRpZpBhbJZpZpKpt3pjUEMjJMZTFjZWSAQBCfnyHTPzg+JLW4JDMvPd4nMoyBAQCy8iLn"

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


var COLLECTION_PATH_DIALOG = "mode/lyv/chat_history/members/history"

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
    
    func generateRandomAlphanumericString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        
        for _ in 0..<length {
            let randomIndex = Int.random(in: 0..<characters.count)
            let index = characters.index(characters.startIndex, offsetBy: randomIndex)
            randomString.append(characters[index])
        }
        
        return randomString
    }
    
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


extension Date {
    
    func dateString(_ format: String = "MM-dd-yyyy, hh:mm a") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func dateStringCustommmm(_ format: String = "dd/MM, hh:mm a") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func dateString2(_ format: String = "yyyy-MM-dd") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func dateByAddingYears(_ dYears: Int) -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = dYears
        
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
    func dateByAddingDays(_ dDays: Int) -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.day = dDays
        
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
}
