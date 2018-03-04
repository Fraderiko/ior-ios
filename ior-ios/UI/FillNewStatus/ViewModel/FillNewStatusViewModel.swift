//
//  FillNewStatusViewModel.swift
//  ior-ios
//
//  Created by me on 23/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class FillNewStatusViewModel {
    
    func update(order: Order, completion: @escaping (Bool, String) -> ()) {
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/order/set-status", parameters: order.prepare()) { (response, error) in
            guard let response = response as? [String: Any] else { return }
            if response["status"] as? String == "error" {
                completion(false, (response["missedFields"] as? [String] ?? []).joined(separator: ", "))
            } else {
                completion(true, "")
            }
        }
    }

}
