//
//  tab_bar_controller.swift
//  LYV
//
//  Created by Dishant Rajput on 31/07/24.
//

import UIKit

class tab_bar_controller: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.unselectedItemTintColor = .white
        tabBar.barTintColor = app_purple_color
        tabBar.isTranslucent = false
        tabBar.backgroundColor = app_BG
        
    }
    
}
