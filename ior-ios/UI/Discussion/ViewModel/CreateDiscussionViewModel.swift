//
//  CreateDiscuissionViewModel.swift
//  ior-ios
//
//  Created by me on 29/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class CreateDiscussionViewModel {
    
    func send(_id: String, discussion: Discussion, completion: @escaping () -> ()) {
        
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/order/add-discussion", parameters: ["_id": "\(_id)", "discussion": discussion.prepare()]) { (response, error) in
            completion()
        }
    }
    
}
