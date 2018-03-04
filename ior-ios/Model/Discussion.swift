//
//  Discussion.swift
//  ior-ios
//
//  Created by me on 29/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

struct Discussion: Encodable, Decodable {
    var date: Double
    var message: String
    var image_media: [String]
    var video_media: [String]
    var author: String
}
