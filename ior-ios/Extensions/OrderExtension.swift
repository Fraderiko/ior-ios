//
//  Order.swift
//  ior-ios
//
//  Created by me on 23/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

extension Order {
    
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
