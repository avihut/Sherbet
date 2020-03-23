//
//  Router.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


typealias RouteResult = Result<String, Error>
typealias RouteHandler = (String) -> RouteResult


struct Router {
    enum RouterError: Error {
        case unknownEndpoint(endpoint: String)
    }
    
    private var routeHandlers: [String : RouteHandler] = [:]
    
    mutating func register(handler: @escaping RouteHandler, for endpoint: String) {
        routeHandlers[endpoint] = handler
    }
    
    func call(endpoint: String, with payload: String) -> RouteResult {
        guard let handler = routeHandlers[endpoint] else {
            return .failure(RouterError.unknownEndpoint(endpoint: endpoint))
        }
        
        return handler(payload)
    }
}
