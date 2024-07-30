//
//  home.swift
//  LYV
//
//  Created by Dishant Rajput on 29/07/24.
//

import UIKit

class home: UIViewController {

    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var txt_search:UITextField! {
        didSet {
            txt_search.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            txt_search.layer.cornerRadius = 25
            txt_search.clipsToBounds = true
            txt_search.placeholder = "Search"
            txt_search.setLeftPaddingPoints(20)
            let placeholderText = "Search"
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            txt_search.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        }
    }
    
    @IBOutlet weak var img_profile:UIImageView! {
        didSet {
            img_profile.layer.cornerRadius = 25
            img_profile.clipsToBounds = true
            img_profile.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var btn_view_all:UIButton! {
        didSet {
            btn_view_all.setTitleColor(app_purple_color, for: .normal)
        }
    }
    
    @IBOutlet weak var collectionView:UICollectionView! {
        didSet {
            collectionView.isPagingEnabled = false
            collectionView.backgroundColor = .clear
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        
        
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
    }
    
}


//MARK:- COLLECTION VIEW -
extension home: UICollectionViewDelegate ,
                     UICollectionViewDataSource ,
                     UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_collection_view_cell", for: indexPath as IndexPath) as! home_collection_view_cell

        cell.backgroundColor  = .clear
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var sizes: CGSize
        let result = UIScreen.main.bounds.size
        NSLog("%f",result.height)
        sizes = CGSize(width: 140, height: 140)
        
        return sizes
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
}

class home_collection_view_cell: UICollectionViewCell , UITextFieldDelegate {
    
    @IBOutlet weak var img_view:UIImageView! {
        didSet {
            img_view.layer.cornerRadius = 12
            img_view.clipsToBounds = true
            img_view.backgroundColor = .brown
        }
    }
    
}
