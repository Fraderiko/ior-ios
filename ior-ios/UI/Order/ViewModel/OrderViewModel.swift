//
//  OrderViewModel.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class OrderViewModel {
    
    func numberOfStatusesToShow(order: Order) -> Int {
        return order.statuses.filter({$0.state == "Filled"}).count
    }
    
    func cancel(order: Order, completion: @escaping () -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/order/cancel", parameters: order.prepare()) { (response, error) in
            //
            completion()
        }
    }
    
    func editOrder(order: Order, completion: @escaping () -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/order/update", parameters: order.prepare()) { (response, error) in
            //
            completion()
        }
    }
    
    func getUserEditPermission(completion: @escaping (Bool) -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/user/\(Settings.userId() ?? "")") { (response, error) in
            //
            
            guard let response = response as? [String: Any] else { return }
            
            completion(response["permission_to_edit_orders"] as? Bool ?? false)
        }
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
}
