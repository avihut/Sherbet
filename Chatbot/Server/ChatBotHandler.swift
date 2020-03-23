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
    
    func startChat(request: String) -> RouteResult {
        return .success("Hello from chatbot!")
    }
}
