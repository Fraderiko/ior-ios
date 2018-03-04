//
//  Order.swift
//  ior-ios
//
//  Created by me on 19/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

struct Order: Decodable, Encodable {
    var _id: String
    var number: String
    var date: Double
    var updated: Double
    var type: OrderType
    var assignedTo: AssignedTo?
    var assignedToGroup: Egroup?
    var comment: String
    var currentstatus: String
    var createdBy: CreatedBy
    var recipientmail: String
    var recipientphone: String
    var client: Client
    var statuses: [Status]
    var cancelReason: String
    var isFav: Bool?
    var discussion: [Discussion]
    var messages: [Message]
    var responsible: String
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case number
        case date
        case updated
        case type
        case assignedTo
        case comment
        case currentstatus
        case createdBy
        case recipientmail
        case client
        case statuses
        case cancelReason
        case discussion
        case recipientphone
        case messages
        case assignedToGroup
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(String.self, forKey: ._id)
        number = try container.decode(String.self, forKey: .number)
        date = try container.decode(Double.self, forKey: .date)
        updated = try container.decode(Double.self, forKey: .updated)
        type = try container.decode(OrderType.self, forKey: .type)
        comment = try container.decode(String.self, forKey: .comment)
        currentstatus = try container.decode(String.self, forKey: .currentstatus)
        createdBy = try container.decode(CreatedBy.self, forKey: .createdBy)
        recipientmail = try container.decode(String.self, forKey: .recipientmail)
        client = try container.decode(Client.self, forKey: .client)
        statuses = try container.decode([Status].self, forKey: .statuses)
        cancelReason = try container.decode(String.self, forKey: .cancelReason)
        discussion = try container.decode([Discussion].self, forKey: .discussion)
        recipientphone = try container.decode(String.self, forKey: .recipientphone)
        messages = try container.decode([Message].self, forKey: .messages)
        isFav = nil
        responsible = ""
        
        if let assignedTo = try container.decodeIfPresent(AssignedTo.self, forKey: .assignedTo) {
            self.assignedTo = assignedTo
            self.responsible = assignedTo.name
        } else {
            self.assignedTo = nil
        }
        
        if let assignedToGroup = try container.decodeIfPresent(Egroup.self, forKey: .assignedToGroup) {
            self.assignedToGroup = assignedToGroup
            self.responsible = assignedToGroup.name
        } else {
            self.assignedToGroup = nil
        }
    }
}
