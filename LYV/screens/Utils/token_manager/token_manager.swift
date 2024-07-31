import UIKit
import Alamofire

class TokenManager {
    
    static let shared = TokenManager()
    
    private init() {}
    
    @objc func refresh_token_WB(completion: @escaping (String?, Error?) -> Void) {
        
        var parameters: [String: Any] = [:]
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String: Any] {
            
            let userId = person["userId"] as! Int
            let userIdString = String(userId)
            
            parameters = [
                "action"    : "gettoken",
                "userId"    : userIdString,
                "email"     : person["email"] as! String,
                "role"      : "Member"
            ]
        }
        
        print("parameters-------\(parameters)")
        
        AF.request(application_base_url, method: .post, parameters: parameters).responseJSON { response in
            
            switch response.result {
            case .success(let data):
                if let JSON = data as? [String: Any] {
                    print(JSON)
                    
                    if let status = JSON["status"] as? String, status.lowercased() == "success" {
                        if let authToken = JSON["AuthToken"] as? String {
                            UserDefaults.standard.set(authToken, forKey: str_save_last_api_token)
                            completion(authToken, nil)
                        } else {
                            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Token not found"])
                            completion(nil, error)
                        }
                    } else {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Request failed"])
                        completion(nil, error)
                    }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid response format"])
                    completion(nil, error)
                }
                
            case .failure(let error):
                print("Error message: \(error)")
                completion(nil, error)
            }
        }
    }
}


import Alamofire

class YourAPIManager {
    
    static let shared = YourAPIManager()
    
    private init() {}
    
    func callAPI(loader: Bool, action: String, userId: Int, parameters: Parameters?, headers: HTTPHeaders?, completion: @escaping (Result<Any, Error>) -> Void) {
        
        if loader {
            ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
        }
        
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String:Any],
           let token_id_is = UserDefaults.standard.string(forKey: str_save_last_api_token) {
            
            let x = person["userId"] as! Int
            let myString = String(x)
            
            let requestHeaders: HTTPHeaders = [
                "token": token_id_is,
            ]
            
            // Merge custom headers if provided
//            if let customHeaders = headers {
//                requestHeaders.merge(customHeaders) { (_, new) in new }
//            }
            
            var apiParameters: Parameters = [
                "action": action,
                "userId": myString,
                // Add any other default parameters needed for the API
            ]
            
            // Merge custom parameters if provided
            if let customParams = parameters {
                apiParameters.merge(customParams) { (_, new) in new }
            }
            
            AF.request(application_base_url, method: .post, parameters: apiParameters, headers: requestHeaders)
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        if let JSON = data as? [String: Any], let status = JSON["status"] as? String {
                            if status.lowercased() == "success" {
                                ERProgressHud.sharedInstance.hide()
                                if let dataArray = JSON["data"] {
                                    completion(.success(dataArray))
                                } else {
                                    completion(.failure(NSError(domain: "API Error", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"])))
                                }
                            } else {
                                completion(.failure(NSError(domain: "API Error", code: 500, userInfo: [NSLocalizedDescriptionKey: "API returned failure status"])))
                            }
                        } else {
                            completion(.failure(NSError(domain: "API Error", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                        }
                        
                    case .failure(let error):
                        print("Error message: \(error.localizedDescription)")
                        ERProgressHud.sharedInstance.hide()
                        completion(.failure(error))
                    }
            }
            
        } else {
            completion(.failure(NSError(domain: "API Error", code: 500, userInfo: [NSLocalizedDescriptionKey: "User data or token not found"])))
        }
    }
}
