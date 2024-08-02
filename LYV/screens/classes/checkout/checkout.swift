//
//  checkout.swift
//  LYV
//
//  Created by Dishant Rajput on 02/08/24.
//

import UIKit

class checkout: UIViewController {

    @IBOutlet weak var btn_next:UIButton! {
        didSet {
            btn_next.backgroundColor = .white
            btn_next.layer.cornerRadius = 25
            btn_next.clipsToBounds = true
            btn_next.setTitle("Continue Shopping", for: .normal)
            btn_next.backgroundColor = app_purple_color
            btn_next.setTitleColor(.white, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = app_BG
        self.btn_next.addTarget(self, action: #selector(nextC), for: .touchUpInside)
    }
    
    @objc func nextC() {
        let push = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "tab_bar_controller_id")
        self.navigationController?.pushViewController(push, animated: true)
    }
}
