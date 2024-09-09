//
//  help.swift
//  LYV
//
//  Created by Dishant Rajput on 05/09/24.
//

import UIKit

class help: UIViewController {

    @IBOutlet weak var btnBack:UIButton! {
        didSet {
            btnBack.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
