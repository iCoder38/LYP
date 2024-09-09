//
//  live_stream_welcome.swift
//  LYV
//
//  Created by Dishant Rajput on 13/08/24.
//

import UIKit

class live_stream_welcome: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txt_password:UITextField! {
        didSet {
            txt_password.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_password.layer.cornerRadius = 25
            txt_password.clipsToBounds = true
            txt_password.placeholder = "Password"
            txt_password.setLeftPaddingPoints(20)
            let placeholderText = "Channel Name"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_password.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
            txt_password.textColor = .white
        }
    }
    
    @IBOutlet weak var btn_sign_in:UIButton! {
        didSet {
            btn_sign_in.backgroundColor = .white
            btn_sign_in.layer.cornerRadius = 25
            btn_sign_in.clipsToBounds = true
            btn_sign_in.setTitle("Start Live Broadcast", for: .normal)
            btn_sign_in.backgroundColor = app_purple_color
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txt_password.delegate = self
        self.btn_sign_in.addTarget(self, action: #selector(live_stream_c_m), for: .touchUpInside)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        super.view.endEditing(true)
    }
    
    @objc func live_stream_c_m() {
        super.view.endEditing(true)
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "liveStreamingController_id") as? liveStreamingController
        
        push!.str_audience = "no"
        push!.str_channel_name = String(self.txt_password.text!)
        // push!.str_channel_name = "iOS_Testing_LYV"
        
        self.navigationController?.pushViewController(push!, animated: true)
    }
    
}
