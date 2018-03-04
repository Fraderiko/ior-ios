//
//  CreateOrderViewModel.swift
//  ior-ios
//
//  Created by me on 25/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class CreateOrderViewModel {
    
    func getCanWorkWith(completion: @escaping ([User], [Egroup], [OrderTemplate]) -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/group-by-user/", parameters: ["_id": Settings.userId() ?? ""]) { (response, error) in
            guard let response = response as? [String : Any] else { return }
            guard let canWorkWith = response["canworkwith"] as? [[String: Any]] else { return }
            guard let orders = response["orders"] as? [[String: Any]] else { return }
            
            var egroups: [Egroup] = []
            
            if let canWorkWithGroups = response["canworkwithgroups"] as? [[String: Any]] {
                let jsonData = try! JSONSerialization.data(withJSONObject: canWorkWithGroups, options: [])
                let jsonString = String(data: jsonData ?? Data(), encoding: .utf8) ?? ""
                let data = jsonString.data(using: .utf8)
                egroups = try! JSONDecoder().decode([Egroup].self, from: data!)
            }
            
            let jsonData = try! JSONSerialization.data(withJSONObject: canWorkWith, options: [])
            let jsonString = String(data: jsonData ?? Data(), encoding: .utf8) ?? ""
            let data = jsonString.data(using: .utf8)
            var users = try! JSONDecoder().decode([User].self, from: data!)
            
            let ordersJsonData = try! JSONSerialization.data(withJSONObject: orders, options: [])
            let ordersJsonString = String(data: ordersJsonData ?? Data(), encoding: .utf8) ?? ""
            let ordersData = ordersJsonString.data(using: .utf8)
            
            do {
                var orderTemplates = try JSONDecoder().decode([OrderTemplate].self, from: ordersData!)
                completion(users, egroups, orderTemplates)
            } catch {
                print(error)
            }
            
            
        }
    }
    
    func getTemplates(completion: @escaping ([OrderTemplate]) -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/order-templates/", parameters: ["_id": Settings.userId() ?? ""]) { (response, error) in
            guard let response = response as? [[String : Any]] else { return }
            
            let jsonData = try! JSONSerialization.data(withJSONObject: response, options: [])
            let jsonString = String(data: jsonData ?? Data(), encoding: .utf8) ?? ""
            let data = jsonString.data(using: .utf8)
            var templates = try! JSONDecoder().decode([OrderTemplate].self, from: data!)
            
            completion(templates)
        }
    }
    
    func getGroup(_id: String, completion: @escaping (String) -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/group/\(_id)", parameters: [:]) { (response, error) in
            guard let response = response as? [String : Any] else { return }
            let _id = response["_id"] as? String ?? ""
            
            completion(_id)
        }
    }
    
    func createOrder(order: NewOrder, completion: @escaping (Bool) -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/order/create", parameters: order.prepare()) { (response, error) in
            guard let response = response as? [String : Any] else { return }
            
            let result = response["result"] as? String ?? ""
            
            if result == "ok" {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
