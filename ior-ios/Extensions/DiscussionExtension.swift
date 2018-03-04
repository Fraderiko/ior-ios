//
//  DiscussionExtension.swift
//  ior-ios
//
//  Created by me on 29/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

extension Discussion {
    
    func prepare() -> [String: Any] {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            return (String(data: jsonData, encoding: .utf8) ?? "").convertToDictionary() ?? [:]
        }
        catch {
            print(error)
        }
        return [:]
    }
    
}
