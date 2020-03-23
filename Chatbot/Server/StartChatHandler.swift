//
//  Server.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


struct StartChatHandler: JsonRequestHandling {
    typealias Request = StartChatRequest
    typealias Response = StartChatResponse
    
    func handle(parsedRequest request: StartChatRequest) -> StartChatResponse {
        return startChat(token: request.token)
    }
    
    fileprivate func startChat(token: String) -> StartChatResponse {
        return StartChatResponse(messages: ["Hello from chatbot!"])
    }
}
