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
    }
    
    func createApp() -> Router {
        var router = Router()
        
        router.register(handler: ChatBotHandler().startChat(request:), for: .startChat)
        
        return router
    }
}


extension Router {
    mutating func register(handler: @escaping RouteHandler, for endpoint: ChatbotWebApp.endpoint) {
        register(handler: handler, for: endpoint.rawValue)
    }
    
    func call(endpoint: ChatbotWebApp.endpoint, with payload: String) -> RouteResult {
        return call(endpoint: endpoint.rawValue, with: payload)
    }
}
