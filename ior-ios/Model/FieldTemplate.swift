//
//  FieldTemplate.swift
//  ior-ios
//
//  Created by me on 26/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit

struct FieldTemplate: Encodable, Decodable {
    var name: String
    var type: String
    var value: String
    var required: Bool
    var recepientvisible: Bool
    var media: [String]
}
