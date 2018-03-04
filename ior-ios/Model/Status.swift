//
//  Status.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class Status: Decodable, Encodable {
    var name: String
    var _id: String
    var fields: [Field]
    var state: String
    var isFinal: Bool
    var groups_permission_to_edit: [String]
    var users_permission_to_edit: [String]
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case _id = "_id"
        case fields = "fields"
        case state = "state"
        case isFinal = "isFinal"
        case groups_permission_to_edit
        case users_permission_to_edit
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let name = try container.decodeIfPresent(String.self, forKey: .name) {
            self.name = name
        } else {
            self.name = ""
        }
        
        if let _id = try container.decodeIfPresent(String.self, forKey: ._id) {
            self._id = _id
        } else {
            self._id = ""
        }
        
        if let fields = try container.decodeIfPresent([Field].self, forKey: .fields) {
            self.fields = fields
        } else {
            self.fields = []
        }
        
        if let state = try container.decodeIfPresent(String.self, forKey: .state) {
            self.state = state
        } else {
            self.state = ""
        }
        
        if let isFinal = try container.decodeIfPresent(Bool.self, forKey: .isFinal) {
            self.isFinal = isFinal
        } else {
            self.isFinal = false
        }
        
        if let groups_permission_to_edit = try container.decodeIfPresent([String].self, forKey: .groups_permission_to_edit) {
            self.groups_permission_to_edit = groups_permission_to_edit
        } else {
            self.groups_permission_to_edit = []
        }
        
        if let users_permission_to_edit = try container.decodeIfPresent([String].self, forKey: .users_permission_to_edit) {
            self.users_permission_to_edit = users_permission_to_edit
        } else {
            self.users_permission_to_edit = []
        }
    }
}
