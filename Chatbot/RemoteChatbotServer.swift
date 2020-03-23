//
//  RemoteChatbotServer.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


enum ChatbotServerEndpoint: String {
    case startChat = "/start_chat"
}


protocol RemoteChatbotServer {
    func startChat(withToken token: String, withHandler completionHandler: (Result<StartChatResponse, Error>) -> ())
}


struct MockLocalChatbotServer: RemoteChatbotServer {
    enum ServerError: Error {
        case failedParsingResponse
    }
    
    private let mockServer: Router
    
    init(mockServer: Router) {
        self.mockServer = mockServer
    }
    
    func startChat(withToken token: String, withHandler completionHandler: (Result<StartChatResponse, Error>) -> ()) {
        let startChatRequest = StartChatRequest(token: token)
        post(to: .startChat, request: startChatRequest, completionHandler: completionHandler)
    }
    
    private func post<Request: Encodable, Response: Decodable>(to endpoint: ChatbotServerEndpoint, request: Request, completionHandler: (Result<Response, Error>) -> ()) {
        let payload = try? JSONEncoder().encode(request)
        let payloadData = sanitize(payload: payload)
        let result = mockServer.call(endpoint: endpoint.rawValue, with: payloadData)
        
        switch result {
        case .success(let responseData):
            guard let response = try? JSONDecoder().decode(Response.self, from: responseData) else {
                completionHandler(.failure(ServerError.failedParsingResponse))
                return
            }
            completionHandler(.success(response))
            
        case .failure(let error):
            completionHandler(.failure(error))
        }
    }
    
    private func sanitize(payload: Data?) -> Data {
        let payloadData: Data
        if let payload = payload {
            payloadData = payload
        } else {
            payloadData = try! JSONEncoder().encode("{}".data(using: .utf8)!)
        }
        return payloadData
    }
}


struct StartChatRequest: Codable {
    let token: String
}

struct StartChatResponse: Codable {
    let messages: [String]
}
