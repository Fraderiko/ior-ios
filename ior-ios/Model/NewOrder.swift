//
//  OrderTemplate.swift
//  ior-ios
//
//  Created by me on 26/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

struct NewOrder: Encodable, Decodable {
    var number: String
    var date: Double
    var updated: Double
    var type: String
    var currentstatus: String
    var assignedTo: String
    var assignedToGroup: String
    var comment: String
    var statuses: [StatusTemplate]
    var createdBy: String
    var group: String
    var recipientmail: String
    var recipientphone: String
    var client: String
    var cancelReason: String
    var discussion: [Discussion]
    var isArchived: Bool
}
