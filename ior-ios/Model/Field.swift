//
//  Field.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class Field: Decodable, Encodable {
    var name: String
    var type: String
    var value: String
    var required: Bool
    var recepientvisible: Bool
    var _id: String
    var media: [String]
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case _id = "_id"
        case value = "value"
        case required = "required"
        case type = "type"
        case recepientvisible = "recepientvisible"
        case media = "media"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let required = try container.decodeIfPresent(Bool.self, forKey: .required) {
            self.required = required
        } else {
            self.required = false
        }
        
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
        
        if let value = try container.decodeIfPresent(String.self, forKey: .value) {
            self.value = value
        } else {
            self.value = ""
        }
        
        if let type = try container.decodeIfPresent(String.self, forKey: .type) {
            self.type = type
        } else {
            self.type = ""
        }
        
        if let recepientvisible = try container.decodeIfPresent(Bool.self, forKey: .recepientvisible) {
            self.recepientvisible = recepientvisible
        } else {
            self.recepientvisible = false
        }
        
        if let media = try container.decodeIfPresent([String].self, forKey: .media) {
            self.media = media
        } else {
            self.media = []
        }
        
    }
}
