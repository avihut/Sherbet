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
    
    func handle(parsedRequest: Request) -> Result<Response, Error>
}

extension JsonRequestHandling where Request: Decodable, Response: Encodable {
    func handle(request requestData: Data) -> RouteResult {
        guard let request = try? JSONDecoder().decode(Request.self, from: requestData) else {
            return .failure(RequestError.failedParsingRequest)
        }
        
        let result = handle(parsedRequest: request)
        switch result {
        case .success(let responseData):
            guard let response = try? JSONEncoder().encode(responseData) else {
                return .failure(Router.RouterError.internalError)
            }
            return .success(response)
            
        case .failure(let error):
            return .failure(error)
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
