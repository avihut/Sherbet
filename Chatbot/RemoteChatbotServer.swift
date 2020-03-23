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
        let payload = try? JSONEncoder().encode(startChatRequest)
        post(to: .startChat, payload: payload) { result in
            switch result {
            case .success(let response):
                guard let startChatResponse = try? JSONDecoder().decode(StartChatResponse.self, from: response) else {
                    completionHandler(.failure(ServerError.failedParsingResponse))
                    return
                }
                
                completionHandler(.success(startChatResponse))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private func post(to endpoint: ChatbotServerEndpoint, payload: Data?, completionHandler: (Result<Data, Error>) -> ()) {
        let payloadData: Data
        if let payload = payload {
            payloadData = payload
        } else {
            payloadData = try! JSONEncoder().encode("{}".data(using: .utf8)!)
        }
        
        let result = mockServer.call(endpoint: ChatbotServerEndpoint.startChat.rawValue, with: payloadData)
        completionHandler(result)
    }
}


struct StartChatRequest: Codable {
    let token: String
}

struct StartChatResponse: Codable {
    let messages: [String]
}
