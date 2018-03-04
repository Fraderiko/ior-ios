//
//  APIManager.swift
//  ior-ios
//
//  Created by me on 19/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import Alamofire

struct APIMode {
    
    #if DEBUG
    static let Backend: String = "http://127.0.0.1:3000"
    static let SocketsBackend: String = "http://127.0.0.1"
    #else
    static let Backend: String = "http://188.225.47.101"
    static let SocketsBackend: String = "http://188.225.47.101"
    #endif
}

class APIManager {
    
    static let shared = APIManager()
    private let errorProcessor = APIErrorProcessor()
    
    lazy var sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 20
        var sessionManager = Alamofire.SessionManager(configuration: configuration)
        return sessionManager
    }()
    
    func baseRequest(mode: String, method: HTTPMethod, endPoint: String, parameters: [String: Any] = [:], encoding: ParameterEncoding,  completion: @escaping (Any, APIManagerError?) -> ()) {
        guard let url = URL(string: mode + endPoint) else { return }
        
        sessionManager.request(url, method: method, parameters: parameters, encoding: encoding).logRequest(.verbose).validate().responseJSON { [unowned self] (response) in
            
            let error : APIManagerError? = self.errorProcessor.checkForError(response)
            
            switch response.result {
                
            case .failure(let error):
                print("##########")
                print("Response code is \(response.response?.statusCode ?? 0)")
                print(APIManagerError.custom(error.localizedDescription))
                print("##########")
                
                var result: [String: Any] = [:]
                
                if let response = response.value as? [String: Any] {
                    result = response
                }

                if response.response == nil {
                    completion(result, APIManagerError.noInternetConnection)
                    return
                } else {
                    completion(result, APIManagerError.other)
                    return
                }
                
            case .success(let value):
                print("response is \(response.value ?? "")")
                completion(response.value, error)
            }
        }
    }
    
    func getRequest(mode: String, endPoint: String, completion: @escaping (Any, APIManagerError?)->()) {
        baseRequest(mode: mode, method: .get, endPoint: endPoint, encoding: URLEncoding.default, completion: completion)
    }
    
    func postRequest(mode: String, endPoint: String, parameters: [String: Any] = [:], completion: @escaping (Any, APIManagerError?) -> ()) {
        baseRequest(mode: mode, method: .post, endPoint: endPoint, parameters: parameters, encoding: JSONEncoding.default,  completion: completion)
    }
}

enum APIManagerError: Error {
    case noInternetConnection
    case custom(String)
    case other
}

extension APIManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "Отсутствует интернет соединение"
        case .other:
            return "Что-то пошло не так"
        case .custom(let message):
            return message
        }
    }
}

extension APIManagerError {
    init(_ dict: [String : Any]) {
        let status = dict["status"] as? String ?? ""
        if status == "error" {
            self = .custom(dict["errorText"] as? String ?? "")
        } else {
            self = .other
        }
    }
}

class APIErrorProcessor: NSObject {
    func checkForError(_ requestReponse : DataResponse<Any>) -> APIManagerError? {
        if let response = requestReponse.result.value as? [String: Any] {
            if let status = response["status"] as? String {
                if status == "error" {
                    return APIManagerError(response)
                }
            }
        }
        return nil
    }
    
    class func errorDescription(_ error:APIManagerError) -> String {
        guard let description = error.errorDescription else { return "Что-то пошло не так" }
        return description
    }
}
