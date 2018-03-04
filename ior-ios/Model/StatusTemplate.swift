//
//  StatusTemplate.swift
//  ior-ios
//
//  Created by me on 26/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

struct StatusTemplate: Encodable, Decodable {
    var name: String
    var fields: [FieldTemplate]
    var users_permission_to_edit: [String]
    var groups_permission_to_edit: [String]
    var isFinal: Bool
    
    private enum CodingKeys: String, CodingKey {
        case name
        case fields
        case users_permission_to_edit
        case groups_permission_to_edit
        case isFinal
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        fields = try container.decode([FieldTemplate].self, forKey: .fields)
        isFinal = try container.decode(Bool.self, forKey: .isFinal)
        
        if let users_permission_to_edit = try container.decodeIfPresent([String].self, forKey: .users_permission_to_edit) {
            self.users_permission_to_edit = users_permission_to_edit
        } else {
            self.users_permission_to_edit = []
        }
        
        if let groups_permission_to_edit = try container.decodeIfPresent([String].self, forKey: .groups_permission_to_edit) {
            self.groups_permission_to_edit = groups_permission_to_edit
        } else {
            self.groups_permission_to_edit = []
        }
    }
}
