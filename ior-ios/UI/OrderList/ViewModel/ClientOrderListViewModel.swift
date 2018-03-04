//
//  ClientOrderListViewModel.swift
//  ior-ios
//
//  Created by me on 19/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class ClientOrderListViewModel {
    
    func fetchOrders(completion: @escaping ([Order]) -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/user/\(Settings.userId() ?? "")", parameters: [:], completion: { (response, error) in
                guard let response = response as? [String: Any] else { return }
                let favs = response["favorites"] as? [String] ?? []
                
            if Settings.userType() == .Employee {
                APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/order-by-employee/\(Settings.userId() ?? "")") { (response, error) in
                    guard let response = response as? [[String: Any]] else {
                        return
                    }
                    
                    let jsonData = try! JSONSerialization.data(withJSONObject: response, options: [])
                    let jsonString = String(data: jsonData ?? Data(), encoding: .utf8) ?? ""
                    let data = jsonString.data(using: .utf8)
                    
                    do {
                        var orders = try JSONDecoder().decode([Order].self, from: data!)
                        
                        var ordersCopy = orders
                        
                        for (index, value) in ordersCopy.enumerated() {
                            if favs.contains(value._id) {
                                orders[index].isFav = true
                            }
                        }
                        
                        completion(orders)
                    } catch {
                        print(error)
                    }
                    
                    
                    
                }
            } else {
                APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/order-by-group/\(Settings.userId() ?? "")") { (response, error) in
                    guard let response = response as? [[String: Any]] else { return }
                
                    let jsonData = try! JSONSerialization.data(withJSONObject: response, options: [])
                    let jsonString = String(data: jsonData ?? Data(), encoding: .utf8) ?? ""
                    let data = jsonString.data(using: .utf8)
                    var orders = try! JSONDecoder().decode([Order].self, from: data!)
                
                    var ordersCopy = orders
                    
                    for (index, value) in ordersCopy.enumerated() {
                        if favs.contains(value._id) {
                            orders[index].isFav = true
                        }
                    }
                    
                    completion(orders)
                }
            }
        })
    }
    
    func addToFav(_id: String, order_id: String, completion: @escaping () -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/addfavorder/", parameters: ["_id": "\(_id)", "order_id": "\(order_id)"]) { (response, error) in
            completion()
        }
    }
    
    func removeFromFav(_id: String, order_id: String, completion: @escaping () -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/removefavorder/", parameters: ["_id": "\(_id)", "order_id": "\(order_id)"]) { (response, error) in
            completion()
        }
    }
    
    func setUserPushID(push_id: String) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/users/set-push-id", parameters: ["_id": Settings.userId() ?? "", "push_id" : push_id]) { (response, error) in
            //
        }
    }
}
