import UIKit
import Alamofire

class ReviewPopupViewController: UIViewController {
    
    var reviewTo:String!
    var selectedStar:String!
    var strEnteredMessage:String!
    
    // MARK: - UI Components -
    let containerView = UIView()
    let starsStackView = UIStackView()
    var starButtons: [UIButton] = []
    var selectedRating: Int = 0
    let commentTextView = UITextView()
    let sendReviewButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.reviewTo as Any)
        
        setupContainerView()
        setupUI()
    }
    
    private func setupContainerView() {
        // Container View with rounded corners
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Center the container in the middle of the screen with specific height/width
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        starsStackView.axis = .horizontal
        starsStackView.distribution = .fillEqually
        starsStackView.spacing = 8
        containerView.addSubview(starsStackView)
        
        // Add Star Buttons
        for i in 1...5 {
            let starButton = UIButton(type: .system)
            starButton.setTitle("★", for: .normal)
            starButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            starButton.tag = i
            starButton.setTitleColor(.lightGray, for: .normal)
            starButton.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            starsStackView.addArrangedSubview(starButton)
            starButtons.append(starButton)
        }
        
        // Comment Text View
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.cornerRadius = 8
        commentTextView.font = UIFont.systemFont(ofSize: 16)
        commentTextView.textColor = .darkGray
        commentTextView.text = ""
        commentTextView.textAlignment = .left
        commentTextView.isScrollEnabled = false
        containerView.addSubview(commentTextView)
        
        // Send Review Button
        sendReviewButton.setTitle("Send Review", for: .normal)
        sendReviewButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        sendReviewButton.backgroundColor = .systemBlue
        sendReviewButton.setTitleColor(.white, for: .normal)
        sendReviewButton.layer.cornerRadius = 8
        sendReviewButton.addTarget(self, action: #selector(sendReviewTapped), for: .touchUpInside)
        containerView.addSubview(sendReviewButton)
        
        // Setup Constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        starsStackView.translatesAutoresizingMaskIntoConstraints = false
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        sendReviewButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            starsStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            starsStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            starsStackView.heightAnchor.constraint(equalToConstant: 40),
            
            commentTextView.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 20),
            commentTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            commentTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            commentTextView.heightAnchor.constraint(equalToConstant: 80),
            
            sendReviewButton.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 20),
            sendReviewButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            sendReviewButton.widthAnchor.constraint(equalToConstant: 150),
            sendReviewButton.heightAnchor.constraint(equalToConstant: 50),
            sendReviewButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Button Actions
    @objc private func starButtonTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStarColors()
    }
    
    private func updateStarColors() {
        for (index, button) in starButtons.enumerated() {
            button.setTitleColor(index < selectedRating ? .systemYellow : .lightGray, for: .normal)
        }
    }
    
    @objc private func sendReviewTapped() {
        let comment = commentTextView.text
        print("User selected \(selectedRating) stars and comment: \(comment ?? "")")
        
        self.selectedStar = "\(selectedRating)"
        self.strEnteredMessage = "\(comment!)"
        
        dismiss(animated: true, completion: nil)
        
        sendReviewWB(loader: "yes")
    }
    
    @objc func sendReviewWB(loader:String) {
       
        var parameters:Dictionary<AnyHashable, Any>!
        
        if (loader == "yes") {
            ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        }
       
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any] {
            print(person)
            
            let x : Int = person["userId"] as! Int
            let myString = String(x)
            
            if let token_id_is = UserDefaults.standard.string(forKey: str_save_last_api_token) {
                
                let headers: HTTPHeaders = [
                    "token":String(token_id_is),
                ]
                 /*
                  self.selectedStar = "\(selectedRating)"
                  self.strEnteredMessage = "\(comment!)"
                  */
                parameters = [
                    "action"        : "submitreview",
                    "reviewFrom"    : String(myString),
                    "reviewTo"      : String(self.reviewTo),
                    "star"          : String(self.selectedStar),
                    "message"       : String(self.strEnteredMessage)
                ]
                
                print("parameters-------\(String(describing: parameters))")
                
                AF.request(application_base_url, method: .post, parameters: parameters as? Parameters,headers: headers).responseJSON { [self]
                    response in
                    
                    switch(response.result) {
                    case .success(_):
                        if let data = response.value {
                            
                            let JSON = data as! NSDictionary
                            print(JSON)
                            
                            var strSuccess : String!
                            strSuccess = JSON["status"] as? String
                            
                            if strSuccess.lowercased() == "success" {
                                ERProgressHud.sharedInstance.hide()
                                // var ar : NSArray!
                                // ar = (JSON["data"] as! Array<Any>) as NSArray
                                
                                /*self.arrNotificationsList.removeAllObjects()
                                self.arrNotificationsList.addObjects(from: ar as! [Any])
                                self.tble_view.delegate = self
                                self.tble_view.dataSource = self*/
                                
                                // self.tble_view.reloadData()
                            }
                            else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        print("Token received: \(token)")
                                        
                                        let str_token = "\(token)"
                                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                                        
                                        self.sendReviewWB(loader: "no")
                                        
                                    } else if let error = error {
                                        print("Failed to refresh token: \(error.localizedDescription)")
                                        // Handle the error
                                    }
                                }

                            }
                            
                        }
                        
                    case .failure(_):
                        print("Error message:\(String(describing: response.error))")
                        ERProgressHud.sharedInstance.hide()
                        self.please_check_your_internet_connection()
                        
                        break
                    }
                }
            } else {
                TokenManager.shared.refresh_token_WB { token, error in
                    if let token = token {
                        print("Token received: \(token)")
                        
                        let str_token = "\(token)"
                        UserDefaults.standard.set("", forKey: str_save_last_api_token)
                        UserDefaults.standard.set(str_token, forKey: str_save_last_api_token)
                        
                        self.sendReviewWB(loader: "no")
                        
                    } else if let error = error {
                        print("Failed to refresh token: \(error.localizedDescription)")
                        // Handle the error
                    }
                }
            }
        }
        
    }
}

