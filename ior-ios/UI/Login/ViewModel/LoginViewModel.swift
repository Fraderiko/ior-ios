//
//  LoginViewModel.swift
//  ior-ios
//
//  Created by me on 19/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class LoginViewModel {
    
    func auth(login: String, password: String, completion: @escaping ([String: Any]) -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/users/auth", parameters: ["mail": login, "password": password]) { (response, error) in
            if let response = response as? [String: Any] {
                completion(response)
            }
        }
    }
    
    func performAuth(login: String, password: String, completion: @escaping (Bool) -> ()) {
        auth(login: login, password: password) { (response) in
            if response["result"] as? String ?? "" == "ok" {
                Settings.saveUser(id: response["_id"] as? String ?? "")
                Settings.saveUser(type: response["type"] as? String ?? "")
                Settings.saveOrder(type: response["name"] as? String ?? "")
                
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
}
