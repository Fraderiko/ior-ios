//
//  Upload.swift
//  ior-ios
//
//  Created by me on 22/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class Upload {
    var _id: String
    var url: String
    
    init(_id: String = "", url: String = "") {
        self._id = _id
        self.url = url
    }
    
    init(dict: [String: Any]) {
        self._id = dict["_id"] as? String ?? ""
        self.url = dict["url"] as? String ?? ""
    }
}
