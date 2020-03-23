//
//  Server.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


enum ChatbotError: Error {
    case invalidToken
}


struct StartChatHandler: JsonRequestHandling {
    typealias Request = StartChatRequest
    typealias Response = MessageResponse
    
    private let token = "4EmAIn41rJozc3L5c2YAd4oBjDZ6UF34q4W5WMUKP5FpraqngmeFt866dzmE"
    
    func handle(parsedRequest request: StartChatRequest) -> Result<MessageResponse, Error> {
        return startChat(token: request.token)
    }
    
    private func startChat(token: String) -> Result<MessageResponse, Error> {
        guard token == self.token else {
            return .failure(ChatbotError.invalidToken)
        }
        
        return .success(MessageResponse(
            botQuestion: .whatIsYourName,
            messages: ["Hello, I am Avihu!", "What is your name?"],
            messageFieldPlaceholder: "Your name",
            inputType: .text
        ))
    }
}
