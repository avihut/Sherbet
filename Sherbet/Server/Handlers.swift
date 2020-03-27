//
//  Server.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


enum ChatbotServerError: Error {
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
    
    func handle(parsedRequest request: StartChatRequest) -> Result<MessageResponse, Error> {
        guard RequestAuthenticator().isRequestAuthenticated(request: request) else {
            return .failure(ChatbotServerError.unauthenticatedRequest)
        }
        
        return startChat(token: request.token)
    }
    
    private func startChat(token: String) -> Result<MessageResponse, Error> {
        do {
            let messageReponse = try welcomeBot.render(question: welcomeBot.initialQuestion)
            return .success(messageReponse)
        } catch {
            return .failure(error)
        }
    }
}


struct SendAnswerHandler: JsonRequestHandling {
    typealias Request = SendAnswerRequest
    typealias Response = MessageResponse
    
    func handle(parsedRequest request: SendAnswerRequest) -> Result<MessageResponse, Error> {
        guard RequestAuthenticator().isRequestAuthenticated(request: request) else {
            return .failure(ChatbotServerError.unauthenticatedRequest)
        }
        
        return answerQuestion(lastQuestion: request.botQuestion, answer: request.message)
    }
    
    private func answerQuestion(lastQuestion: Question, answer message: String) -> Result<MessageResponse, Error> {
        do {
            try welcomeBot.processAnswer(message: message, for: lastQuestion)
            if let nextQuestion = try welcomeBot.getQuestion(after: lastQuestion) {
                let messageResponse = try welcomeBot.render(question: nextQuestion)
                return .success(messageResponse)
            } else {
                return .success(welcomeBot.endMessage)
            }
        } catch {
            return .failure(error)
        }
    }
}
