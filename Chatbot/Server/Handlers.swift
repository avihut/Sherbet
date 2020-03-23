//
//  Server.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


struct NotImplementedError: Error {}


enum ChatbotError: Error {
    case unauthenticatedRequest
}


struct RequestAuthenticator {
    private let token = "4EmAIn41rJozc3L5c2YAd4oBjDZ6UF34q4W5WMUKP5FpraqngmeFt866dzmE"
    
    func isRequestAuthenticated(request: TokenHoldingRequest) -> Bool {
        if request.token == token {
            return true
        }
        return false
    }
}


struct StartChatHandler: JsonRequestHandling {
    typealias Request = StartChatRequest
    typealias Response = MessageResponse
    
    private let token = "4EmAIn41rJozc3L5c2YAd4oBjDZ6UF34q4W5WMUKP5FpraqngmeFt866dzmE"
    
    func handle(parsedRequest request: StartChatRequest) -> Result<MessageResponse, Error> {
        guard RequestAuthenticator().isRequestAuthenticated(request: request) else {
            return .failure(ChatbotError.unauthenticatedRequest)
        }
        
        return startChat(token: request.token)
    }
    
    private func startChat(token: String) -> Result<MessageResponse, Error> {
        return .success(MessageResponse(
            botQuestion: .whatIsYourName,
            messages: ["Hello, I am Avihu!", "What is your name?"],
            messageFieldPlaceholder: "Your name",
            inputType: .text
        ))
    }
}


struct SendAnswerHandler: JsonRequestHandling {
    typealias Request = SendAnswerRequest
    typealias Response = MessageResponse
    
    func handle(parsedRequest request: SendAnswerRequest) -> Result<MessageResponse, Error> {
        guard RequestAuthenticator().isRequestAuthenticated(request: request) else {
            return .failure(ChatbotError.unauthenticatedRequest)
        }
        
        return answerQuestion(botQuestion: request.botQuestion, answer: request.message)
    }
    
    private func answerQuestion(botQuestion: BotQuestion, answer: String) -> Result<MessageResponse, Error> {
        return .failure(NotImplementedError())
    }
}
