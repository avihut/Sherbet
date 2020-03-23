//
//  ChatbotWebApp.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


struct ChatbotWebApp {
    enum endpoint: String {
        case startChat = "/start_chat"
        case sendAnswer = "/send_answer"
    }
    
    func createApp() -> Router {
        var router = Router()
        
        router.register(handler: StartChatHandler(), for: .startChat)
        router.register(handler: SendAnswerHandler(), for: .sendAnswer)
        
        return router
    }
}


extension Router {
    mutating func register(handler: RequestHandling, for endpoint: ChatbotWebApp.endpoint) {
        register(handler: handler, for: endpoint.rawValue)
    }
    
    func call(endpoint: ChatbotWebApp.endpoint, with payload: Data) -> RouteResult {
        return call(endpoint: endpoint.rawValue, with: payload)
    }
}
