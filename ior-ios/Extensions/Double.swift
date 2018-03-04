//
//  Double.swift
//  ior-ios
//
//  Created by me on 24/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    func startOfDay() -> TimeInterval {
        let date = Date.init(timeIntervalSince1970: self)
        let timeInterval = date.startOfDay.timeIntervalSince1970
        return timeInterval
    }
    
    func endOfDay() -> TimeInterval {
        let date = Date.init(timeIntervalSince1970: self)
        let timeInterval = date.endOfDay.timeIntervalSince1970
        return timeInterval
    }
    
}
