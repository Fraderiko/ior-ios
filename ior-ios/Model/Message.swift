//
//  Message.swift
//  ior-ios
//
//  Created by Alexey on 24/01/2018.
//  Copyright © 2018 home. All rights reserved.
//

import Foundation

struct Message: Encodable, Decodable {
    var order: String
    var username: String
    var type: String
    var value: String
    var date: Double
    
    init(json: [String: Any]) {
        self.order = json["order"] as? String ?? ""
        self.username = json["username"] as? String ?? ""
        self.type = json["type"] as? String ?? ""
        self.value = json["value"] as? String ?? ""
        self.date = json["date"] as? Double ?? 0
    }
    
    init(order: String, username: String, type: String, value: String, date: Double) {
        self.order = order
        self.username = username
        self.type = type
        self.value = value
        self.date = date
    }
}
