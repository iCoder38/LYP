//
//  Utils.swift
//  LinkedDoc
//
//  Created by Dishant Rajput on 11/03/24.
//

import UIKit

//var  application_base_url = "https://demo4.evirtualservices.net/linkdoc/services/index"
var application_base_url = "https://app.linkeddocapp.com/services/index"
// keys
//
// henry : 37359e35c6msh46cf0ff20f75d55p1d6501jsn59c2c19695ad
var str_rapid_api_key = "37359e35c6msh46cf0ff20f75d55p1d6501jsn59c2c19695ad"

let str_save_login_user_data = "keyLoginFullData"
let str_save_last_api_token = "key_last_api_token"

let your_are_not_auth = "You are not authorize to access the API"

var default_key_language = "key_select_language"
var english_language = "en"
var chinese_language = "ch"
var spanish_language = "sp"

// AIzaSyBnOBYmGv9Pa5JUgxgw52HzcNe95JWii1c
// henry 2 : AIzaSyCKxiD73rXP7059hKRTP57egdBxB_NMkIc
var KGoogleApiKey = "AIzaSyCKxiD73rXP7059hKRTP57egdBxB_NMkIc"

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
