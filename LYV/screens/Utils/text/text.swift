//
//  text.swift
//  LYV
//
//  Created by Dishant Rajput on 29/07/24.
//

import UIKit

// MARK: - LOGIN SCREEN -
var text_login_en = "Login" // line: 42
var text_sign_up_en = "Sign up"

class text: NSObject {

}

class text_language: UIViewController {
    
    class func selected_language_get()->String {
        
        var str_language_prefrence_is:String!
        
        if let language_is = UserDefaults.standard.string(forKey: default_key_language) {
            print(language_is)
            if (language_is == english_language) {
                str_language_prefrence_is = english_language
            } else if (language_is == chinese_language) {
                str_language_prefrence_is = chinese_language
            } else {
                str_language_prefrence_is = spanish_language
            }
        }
        
        return str_language_prefrence_is
    }
    
    
    class func text_convertor_method(status:String)->String {
        var str_language_prefrence_is:String! = "0"
        
        if (status == "#text_login") {
            if (text_language.selected_language_get() == english_language) {
                str_language_prefrence_is = text_login_en
            } else if (text_language.selected_language_get() == chinese_language) {
                // str_language_prefrence_is = text_please_wait_ch
            } else {
                // str_language_prefrence_is = text_please_wait_sp
            }
            
        }
        
        return str_language_prefrence_is
        
    }
}
