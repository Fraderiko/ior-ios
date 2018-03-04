//
//  String.swift
//  ior-ios
//
//  Created by me on 23/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

extension String {
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
