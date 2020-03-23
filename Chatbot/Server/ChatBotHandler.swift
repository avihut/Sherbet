//
//  Server.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


struct ChatBotHandler {
    enum ChatBotError: Error {
        case generalError
    }
    
    fileprivate func startChat(token: String) -> StartChatResponse {
        return StartChatResponse(messages: ["Hello from chatbot!"])
    }
}

extension ChatBotHandler: RequestHandling {
    func handle(request: Data) -> RouteResult {
        guard let startChatRequest = try? JSONDecoder().decode(StartChatRequest.self, from: request) else {
            return .failure(RequestError.failedParsingRequest)
        }
        
        let response = startChat(token: startChatRequest.token)
        if let responseData = try? JSONEncoder().encode(response) {
            return .success(responseData)
        } else {
            return .failure(Router.RouterError.internalError)
        }
    }
}
