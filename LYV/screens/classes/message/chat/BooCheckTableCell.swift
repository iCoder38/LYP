//
//  BooCheckTableCell.swift
//  BooCheck
//
//  Created by apple on 01/04/21.
//

import UIKit


class BooCheckTableCell: UITableViewCell {

    @IBOutlet weak var senderName:UILabel! {
        didSet {
            senderName.text = "Dishant Rajput"
        }
    }
    @IBOutlet weak var senderText:UILabel! {
        didSet {
            senderText.text = "i am text i am text i am text i am text i am text i am text i am text i am text i am text i am text"
        }
    }
    
    @IBOutlet weak var receiverName:UILabel! {
        didSet {
            receiverName.text = "Dishu Rajput"
        }
    }
    
    @IBOutlet weak var receiverText:UILabel! {
        didSet {
            receiverText.text = "i am receiverText i am receiverText i am receiverText i am receiverText i am receiverText i am receiverText i am text i am receiverText i am text i am receiverText"
        }
    }
    
    @IBOutlet weak var viewRight:UIView! {
        didSet {
        }
    }
    
    @IBOutlet weak var viewLeft:UIView! {
        didSet {
            viewLeft.backgroundColor = UIColor.init(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1)
        }
    }
    
    @IBOutlet weak var viewBGImageSender:UIView! {
        didSet {
            viewBGImageSender.layer.cornerRadius = 4
            viewBGImageSender.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var imgSenderAttachment:UIImageView!
    @IBOutlet weak var viewBGImageReceiver:UIView! {
        didSet {
            viewBGImageReceiver.layer.cornerRadius = 4
            viewBGImageReceiver.clipsToBounds = true
            viewBGImageReceiver.backgroundColor = UIColor.init(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1)
        }
    }
    
    @IBOutlet weak var imgReceiverAttachment:UIImageView!
    @IBOutlet weak var imgSender:UIImageView! {
        didSet {
            imgSender.layer.cornerRadius = 20
            imgSender.clipsToBounds = true
            imgSender.layer.borderColor = UIColor.white.cgColor
            imgSender.layer.borderWidth = 0.8
         }
    }
    @IBOutlet weak var imgReceiver:UIImageView! {
        didSet {
            imgReceiver.layer.cornerRadius = 20
            imgReceiver.clipsToBounds = true
            imgReceiver.layer.borderColor = UIColor.white.cgColor
            imgReceiver.layer.borderWidth = 0.8
         }
    }
    @IBOutlet weak var imgSenderAttachment2:UIImageView! {
        didSet {
            imgSenderAttachment2.layer.cornerRadius = 20
            imgSenderAttachment2.clipsToBounds = true
            imgSenderAttachment2.layer.borderColor = UIColor.white.cgColor
            imgSenderAttachment2.layer.borderWidth = 0.8
         }
    }
    @IBOutlet weak var imgReceiverAttachment2:UIImageView! {
        didSet {
            imgReceiverAttachment2.layer.cornerRadius = 20
            imgReceiverAttachment2.clipsToBounds = true
            imgReceiverAttachment2.layer.borderColor = UIColor.white.cgColor
            imgReceiverAttachment2.layer.borderWidth = 0.8
         }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
