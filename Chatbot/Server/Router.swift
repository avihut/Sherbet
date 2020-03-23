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

protocol JsonRequestHandling: RequestHandling {
    associatedtype Request
    associatedtype Response
    
    func handle(parsedRequest: Request) -> Response
}

extension JsonRequestHandling where Request: Codable, Response: Codable {
    func handle(request requestData: Data) -> RouteResult {
        guard let request = try? JSONDecoder().decode(Request.self, from: requestData) else {
            return .failure(RequestError.failedParsingRequest)
        }
        
        let response = handle(parsedRequest: request)
        if let responseData = try? JSONEncoder().encode(response) {
            return .success(responseData)
        } else {
            return .failure(Router.RouterError.internalError)
        }
    }
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
