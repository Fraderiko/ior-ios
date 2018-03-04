//
//  SocketsService.swift
//  ior-ios
//
//  Created by Alexey on 24/01/2018.
//  Copyright © 2018 home. All rights reserved.
//

import Foundation
import SocketIO

class SocketsService {
    
    static let shared = SocketsService()
    var manager: SocketManager?
    var socket: SocketIOClient?
    
    var orders: [Order] = []
    
    var updateOrderCompletion: ((String, Message) -> ())?
    
    func start() {
        manager = SocketManager(socketURL: URL(string: "\(APIMode.SocketsBackend):3001")!, config: [.log(true), .compress])
        
        if let manager = manager {
            socket = manager.defaultSocket
            
            if let socket = socket {
                socket.on(clientEvent: .connect) {data, ack in
                    print("socket connected")
                    socket.emit("_id", with: [Settings.userId() ?? ""])
                }
                
                socket.connect()
            }
        }
    }
    
    func post(message: Message) {
        if let socket = socket {
            socket.emit("message", ["order": message.order, "date": message.date, "username": message.username, "type": message.type, "value": message.value])
        }
    }
    
    func subscribe(withOrders: [Order]) {
        guard let socket = socket else {
            return
        }
        unsubscribe()
        self.orders = withOrders
        for order in orders {
            socket.on(order._id, callback: { (data, ack) in
                guard let updateOrderCompletion = self.updateOrderCompletion else { return }
                let message = Message(json: data[0] as? [String:Any] ?? [:])
                updateOrderCompletion(order._id, message)
            })
        }
    }
    
    func unsubscribe() {
        if let socket = socket {
            for order in orders {
                socket.off(order._id)
            }
        }
    }
}
