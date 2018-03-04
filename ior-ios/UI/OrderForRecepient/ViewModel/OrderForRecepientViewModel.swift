//
//  OrderForRecepientViewModel.swift
//  ior-ios
//
//  Created by me on 28/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class OrderForRecepientViewModel {
    
    func getOrder(completion: @escaping (Order) -> ()) {
        APIManager.shared.getRequest(mode: APIMode.Backend, endPoint: "/order/\(Settings.orderName() as? String ?? "")") { (response, error) in
            
            let jsonData = try! JSONSerialization.data(withJSONObject: response, options: [])
            let jsonString = String(data: jsonData ?? Data(), encoding: .utf8) ?? ""
            let data = jsonString.data(using: .utf8)
            var order = try! JSONDecoder().decode(Order.self, from: data!)
            
            completion(order)
        }
    }
    
    func prepare(order: Order) -> Order {
        var filteredOrder = order
        
        for (index, value) in order.statuses.enumerated() {
            var fields: [Field] = []
            for field in order.statuses[index].fields {
                if field.type == "video" || field.type == "image" {
                    if field.media.isEmpty == false {
                        fields.append(field)
                    }
                } else {
                    if field.value != "" {
                        fields.append(field)
                    }
                }
            }
            fields = fields.filter({$0.recepientvisible == true})
            filteredOrder.statuses[index].fields = fields
        }
        
        return filteredOrder
    }
    
    func setUserPushID(push_id: String) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/users/set-push-id", parameters: ["_id": Settings.userId() ?? "", "push_id" : push_id]) { (response, error) in
            //
        }
    }
}
