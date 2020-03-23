//
//  Router.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


typealias RouteResult = Result<Data, Error>


enum RequestError: Error {
    case failedParsingRequest
}


protocol RequestHandling {
    func handle(request: Data) -> RouteResult
}


struct Router {
    enum RouterError: Error {
        case unknownEndpoint(endpoint: String)
        case internalError
    }
    
    private var routeHandlers: [String : RequestHandling] = [:]
    
    mutating func register(handler: RequestHandling, for endpoint: String) {
        routeHandlers[endpoint] = handler
    }
    
    func call(endpoint: String, with payload: Data) -> RouteResult {
        guard let handler = routeHandlers[endpoint] else {
            return .failure(RouterError.unknownEndpoint(endpoint: endpoint))
        }
        
        return handler.handle(request: payload)
    }
}
