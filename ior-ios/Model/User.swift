//
//  User.swift
//  ior-ios
//
//  Created by me on 25/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class User: Decodable, Encodable {
    var _id: String
    var type: String
    var name: String
    var mail: String
    var phone: String
    var password: String
    var new_orders_notification: Bool
    var new_status_notification: Bool
    var new_orders_push_notification: Bool
    var new_status_push_notification: Bool
    var permission_to_cancel_orders: Bool
    var permission_to_edit_orders: Bool
    var new_chat_notification: Bool
    var favorites: [String]
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case type
        case name
        case mail
        case phone
        case password
        case new_orders_notification
        case new_status_notification
        case new_orders_push_notification
        case new_status_push_notification
        case permission_to_cancel_orders
        case permission_to_edit_orders
        case new_chat_notification
        case favorites
        
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(String.self, forKey: ._id)
        type = try container.decode(String.self, forKey: .type)
        name = try container.decode(String.self, forKey: .name)
        mail = try container.decode(String.self, forKey: .mail)
        phone = try container.decode(String.self, forKey: .phone)
        password = try container.decode(String.self, forKey: .password)
        new_orders_notification = try container.decode(Bool.self, forKey: .new_orders_notification)
        new_status_notification = try container.decode(Bool.self, forKey: .new_status_notification)
        new_orders_push_notification = try container.decode(Bool.self, forKey: .new_orders_push_notification)
        new_status_push_notification = try container.decode(Bool.self, forKey: .new_status_push_notification)
        permission_to_cancel_orders = try container.decode(Bool.self, forKey: .permission_to_cancel_orders)
        permission_to_edit_orders = try container.decode(Bool.self, forKey: .permission_to_edit_orders)
        favorites = try container.decode([String].self, forKey: .favorites)

        if let new_chat_notification = try container.decodeIfPresent(Bool.self, forKey: .new_chat_notification) {
            self.new_chat_notification = new_chat_notification
        } else {
            self.new_chat_notification = true
        }
    }
}
