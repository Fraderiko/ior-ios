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
    var favorites: [String]
}
