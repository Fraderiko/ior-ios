//
//  Settings.swift
//  ior-ios
//
//  Created by me on 19/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

enum UserType {
    case Client
    case Employee
    case OrderDetails
}

class Settings {
    
    static let shared = Settings()
    
    class func saveUser(id: String) {
        UserDefaults.standard.set(id, forKey: "id")
    }
    
    class func saveUser(type: String) {
        UserDefaults.standard.set(type, forKey: "type")
    }
    
    class func saveOrder(type: String) {
        UserDefaults.standard.set(type, forKey: "name")
    }
    
    class func savePushID(id: String) {
        UserDefaults.standard.set(id, forKey: "pushId")
    }
    
    class func userType() -> UserType? {
        if let type = UserDefaults.standard.value(forKey: "type") as? String {
            if type == "client" {
                return UserType.Client
            } else if type == "employee" {
                return UserType.Employee
            } else {
                return UserType.OrderDetails
            }
        } else {
            return nil
        }
    }
    
    class func userId() -> String? {
        if let id = UserDefaults.standard.value(forKey: "id") as? String {
            return id
        } else {
            return nil
        }
    }
    class func orderName() -> String? {
        if let name = UserDefaults.standard.value(forKey: "name") as? String {
            return name
        } else {
            return nil
        }
    }
    
    class func pushId() -> String {
        if let id = UserDefaults.standard.value(forKey: "pushId") as? String {
            return id
        } else {
            return ""
        }
    }
}
