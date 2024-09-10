import UIKit

class ReviewPopupViewController: UIViewController {
    
    // MARK: - UI Components
    let starsStackView = UIStackView()
    var starButtons: [UIButton] = []
    var selectedRating: Int = 0
    let commentTextView = UITextView()
    let sendReviewButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        
        // Stars Stack View
        starsStackView.axis = .horizontal
        starsStackView.distribution = .fillEqually
        starsStackView.spacing = 8
        view.addSubview(starsStackView)
        
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
        commentTextView.text = "Write your comments here (optional)"
        commentTextView.textAlignment = .left
        commentTextView.isScrollEnabled = false
        view.addSubview(commentTextView)
        
        // Send Review Button
        sendReviewButton.setTitle("Send Review", for: .normal)
        sendReviewButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        sendReviewButton.backgroundColor = .systemBlue
        sendReviewButton.setTitleColor(.white, for: .normal)
        sendReviewButton.layer.cornerRadius = 8
        sendReviewButton.addTarget(self, action: #selector(sendReviewTapped), for: .touchUpInside)
        view.addSubview(sendReviewButton)
        
        // Setup Constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        starsStackView.translatesAutoresizingMaskIntoConstraints = false
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        sendReviewButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            starsStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            starsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starsStackView.heightAnchor.constraint(equalToConstant: 40),
            
            commentTextView.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 20),
            commentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            commentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            commentTextView.heightAnchor.constraint(equalToConstant: 80),
            
            sendReviewButton.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 20),
            sendReviewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendReviewButton.widthAnchor.constraint(equalToConstant: 150),
            sendReviewButton.heightAnchor.constraint(equalToConstant: 50),
            sendReviewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
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
        // Handle the send review action here
        let comment = commentTextView.text
        print("User selected \(selectedRating) stars and comment: \(comment ?? "")")
        dismiss(animated: true, completion: nil)
    }
}

