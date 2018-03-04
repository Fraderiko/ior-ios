//
//  ViewModel.swift
//  ior-ios
//
//  Created by me on 25/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class ProfileViewModel {
    
    func getProfile(completion: @escaping (User) -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/user/\(Settings.userId() ?? "")", parameters: [:]) { (response, error) in
            guard let response = response as? [String: Any] else {
                return
            }
            
            let jsonData = try! JSONSerialization.data(withJSONObject: response, options: [])
            let jsonString = String(data: jsonData ?? Data(), encoding: .utf8) ?? ""
            let data = jsonString.data(using: .utf8)
            let user = try! JSONDecoder().decode(User.self, from: data!)
            
            completion(user)
        }
    }
    
    func updateProfile(user: User, completion: @escaping () -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/users/update", parameters: user.prepare()) { (response, error) in
            
            completion()
        }
    }
}
