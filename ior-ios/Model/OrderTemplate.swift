//
//  OrderTemplate.swift
//  ior-ios
//
//  Created by me on 26/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

struct OrderTemplate: Encodable, Decodable {
    var _id: String
    var name: String
    var statuses: [StatusTemplate]
}
