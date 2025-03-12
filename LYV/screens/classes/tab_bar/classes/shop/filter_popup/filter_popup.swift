import UIKit
import Alamofire
import RangeSeekSlider

// Model for Brand
struct Brand {
    var id: Int
    var name: String
}

class BrandCollectionViewCell: UICollectionViewCell {
    
    var checkboxButton: UIButton!
    var brandLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Create checkbox button
        checkboxButton = UIButton(type: .custom)
        checkboxButton.setImage(UIImage(systemName: "square"), for: .normal) // Empty checkbox
        checkboxButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected) // Selected checkbox
        checkboxButton.tintColor = .white
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkboxButton)
        
        // Create brand label
        brandLabel = UILabel()
        brandLabel.font = UIFont.systemFont(ofSize: 16)
        brandLabel.textColor = .white
        brandLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(brandLabel)
        
        // Set up layout constraints
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 30),
            checkboxButton.heightAnchor.constraint(equalToConstant: 30),
            
            brandLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 10),
            brandLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            brandLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func checkboxTapped() {
        checkboxButton.isSelected.toggle()
    }
}

class BrandSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RangeSeekSliderDelegate {
    
    var collectionView: UICollectionView!
    var brands = [Brand]() // Array of Brand objects
    var selectedBrandIds = [Int]() // Array to track selected brand IDs
    
    var priceRangeSlider: RangeSeekSlider!
    var minPriceLabel: UILabel!
    var maxPriceLabel: UILabel!
    
    var minPriceValue: CGFloat = 100
    var maxPriceValue: CGFloat = 10000
    
    // Buttons for size selection
    var sizeButtons: [UIButton] = []
    var selectedSize: String? // To track selected size

    weak var delegate: BrandSelectionDelegate?
    var onFiltersSelected: ((String, CGFloat, CGFloat, String?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 25/255, green: 30/255, blue: 40/255, alpha: 1) // Dark background
        
        // Fetch brands from the API
        self.fetchAllBrands(loader: "yes")
        
        // Setup Collection View Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // Setup Collection View
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BrandCollectionViewCell.self, forCellWithReuseIdentifier: "brandCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        
        // Add price range slider
        setupPriceRangeSlider()
        
        // Add size buttons
        setupSizeButtons()
        
        // Set a done button for dismissing the popup
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        self.navigationItem.rightBarButtonItem = doneButton
        
        // Setup constraints for the collection view and sliders
        setupConstraints()
    }
    
    // Function to set up the price range slider
    func setupPriceRangeSlider() {
        priceRangeSlider = RangeSeekSlider(frame: .zero)
        priceRangeSlider.delegate = self
        priceRangeSlider.minValue = 100
        priceRangeSlider.maxValue = 10000
        priceRangeSlider.selectedMinValue = minPriceValue
        priceRangeSlider.selectedMaxValue = maxPriceValue
        priceRangeSlider.minDistance = 100 // Minimum difference between the two ends
        priceRangeSlider.handleColor = .purple
        priceRangeSlider.colorBetweenHandles = .purple
        priceRangeSlider.translatesAutoresizingMaskIntoConstraints = false
        
        // Add slider to the view
        self.view.addSubview(priceRangeSlider)
        
        // Min Price Label
        minPriceLabel = UILabel()
        minPriceLabel.textColor = .white
        minPriceLabel.font = UIFont.systemFont(ofSize: 16)
        minPriceLabel.text = "Min: \(Int(minPriceValue))"
        minPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(minPriceLabel)
        
        // Max Price Label
        maxPriceLabel = UILabel()
        maxPriceLabel.textColor = .white
        maxPriceLabel.font = UIFont.systemFont(ofSize: 16)
        maxPriceLabel.text = "Max: \(Int(maxPriceValue))"
        maxPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(maxPriceLabel)
    }
    
    // Function to set up size buttons
    func setupSizeButtons() {
        let sizes = ["XS", "S", "M", "L", "XL", "XXL"]
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 10
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(buttonStackView)
        
        for size in sizes {
            let button = UIButton(type: .system)
            button.setTitle(size, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .clear
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.cgColor
            button.tag = sizes.firstIndex(of: size) ?? 0
            button.addTarget(self, action: #selector(sizeButtonTapped(_:)), for: .touchUpInside)
            
            buttonStackView.addArrangedSubview(button)
            sizeButtons.append(button)
        }
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: maxPriceLabel.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func sizeButtonTapped(_ sender: UIButton) {
        // Deselect all buttons
        for button in sizeButtons {
            button.backgroundColor = .clear
            button.setTitleColor(.white, for: .normal)
        }
        
        // Select the tapped button
        sender.backgroundColor = .purple
        sender.setTitleColor(.white, for: .normal)
        selectedSize = sender.title(for: .normal)
        
        print("Selected Size: \(selectedSize ?? "None")")
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Collection view constraints
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 300),
            
            // Price Range Slider Constraints
            priceRangeSlider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            priceRangeSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            priceRangeSlider.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            
            // Min Price Label Constraints
            minPriceLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            minPriceLabel.topAnchor.constraint(equalTo: priceRangeSlider.bottomAnchor, constant: 10),
            
            // Max Price Label Constraints
            maxPriceLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            maxPriceLabel.topAnchor.constraint(equalTo: priceRangeSlider.bottomAnchor, constant: 10)
        ])
    }
    
    // Delegate method to track changes in the range slider
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        minPriceValue = minValue
        maxPriceValue = maxValue
        minPriceLabel.text = "Min: \(Int(minPriceValue))"
        maxPriceLabel.text = "Max: \(Int(maxPriceValue))"
    }
    
    // Fetch all brands from your API
    @objc func fetchAllBrands(loader: String) {
        var parameters: Dictionary<AnyHashable, Any>!
        
        if (loader == "yes") {
            ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        }
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String: Any] {
            let userId = person["userId"] as! Int
            let myString = String(userId)
            
            if let token_id_is = UserDefaults.standard.string(forKey: str_save_last_api_token) {
                let headers: HTTPHeaders = [
                    "token": String(token_id_is),
                ]
                
                parameters = [
                    "action"    : "productlist",
                    "userId"    : myString,
                    "category"  : "1",
                ]
                
                AF.request(application_base_url, method: .post, parameters: parameters as? Parameters, headers: headers).responseJSON { [self] response in
                    switch(response.result) {
                    case .success(_):
                        if let data = response.value as? NSDictionary {
                            let status = data["status"] as? String
                            if status?.lowercased() == "success" {
                                ERProgressHud.sharedInstance.hide()
                                
                                if let brandlist = data["brandlist"] as? [[String: Any]] {
                                    for brandData in brandlist {
                                        if let id = brandData["id"] as? Int, let name = brandData["name"] as? String {
                                            let brand = Brand(id: id, name: name)
                                            brands.append(brand)
                                        }
                                    }
                                }
                                
                                collectionView.reloadData()
                            } else {
                                TokenManager.shared.refresh_token_WB { token, error in
                                    if let token = token {
                                        UserDefaults.standard.set(token, forKey: str_save_last_api_token)
                                        self.fetchAllBrands(loader: "no")
                                    } else {
                                        print("Failed to refresh token: \(error?.localizedDescription ?? "Unknown error")")
                                    }
                                }
                            }
                        }
                        
                    case .failure(_):
                        print("Error message: \(String(describing: response.error))")
                        ERProgressHud.sharedInstance.hide()
                        self.please_check_your_internet_connection()
                    }
                }
            } else {
                TokenManager.shared.refresh_token_WB { token, error in
                    if let token = token {
                        UserDefaults.standard.set(token, forKey: str_save_last_api_token)
                        self.fetchAllBrands(loader: "no")
                    } else {
                        print("Failed to refresh token: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
    
    @objc func doneTapped() {
        let selectedBrandIdsString = selectedBrandIds.map { String($0) }.joined(separator: ",")
            
            delegate?.didSelectFilters(brands: selectedBrandIdsString, minPrice: minPriceValue, maxPrice: maxPriceValue, size: selectedSize)
            onFiltersSelected?(selectedBrandIdsString, minPriceValue, maxPriceValue, selectedSize)
            
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Collection View DataSource -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return brands.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "brandCell", for: indexPath) as! BrandCollectionViewCell
        let brand = brands[indexPath.row]
        
        cell.brandLabel.text = brand.name
        cell.checkboxButton.isSelected = selectedBrandIds.contains(brand.id)
        
        return cell
    }
    
    // MARK: - Collection View Delegate -
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBrand = brands[indexPath.row]
        
        if let index = selectedBrandIds.firstIndex(of: selectedBrand.id) {
            selectedBrandIds.remove(at: index)
        } else {
            selectedBrandIds.append(selectedBrand.id)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    // MARK: - Collection View Layout -
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 60) / 2
        return CGSize(width: width, height: 50)
    }
}

protocol BrandSelectionDelegate: AnyObject {
    func didSelectFilters(brands: String, minPrice: CGFloat, maxPrice: CGFloat, size: String?)
}
