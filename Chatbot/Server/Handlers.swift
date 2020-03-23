//
//  Server.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


enum BotQuestion: Int, Codable {
    case whatIsYourName = 0
    case whatIsYourPhoneNumber = 1
    case doYouAgreeToServiceTerms = 2
    case whatToDoNowThatYouFinished = 3
}


struct AttributableMessage {
    let text: String
    let attributeNames: [String]
    
    func format(with attributeValues: [String]) -> String {
        return String(format: text, arguments: attributeValues)
    }
}


struct QuestionDefinition {
    let messages: [AttributableMessage]
    let responseHint: String?
    let responseInput: AnswerInputType
    let responseAttributeName: String?
}


struct Questionnaire {
    let initialQuestion: BotQuestion
    let questionCourse: [BotQuestion : BotQuestion?]
    let questionDefinitions: [BotQuestion : QuestionDefinition]
    let endResponse: [AttributableMessage]
}


let welcomeQuestionnaire = Questionnaire(
    initialQuestion: .whatIsYourName,
    questionCourse: [
        .whatIsYourName             : .whatIsYourPhoneNumber,
        .whatIsYourPhoneNumber      : .doYouAgreeToServiceTerms,
        .doYouAgreeToServiceTerms   : .whatToDoNowThatYouFinished,
        .whatToDoNowThatYouFinished : nil
    ],
    questionDefinitions: [
        .whatIsYourName : QuestionDefinition(
            messages: [
                AttributableMessage(text: "Hello, I am %@!", attributeNames: ["bot_name"]),
                AttributableMessage(text: "What is your name?", attributeNames: [])
            ],
            responseHint: "Your name",
            responseInput: .text,
            responseAttributeName: "user_name"
        ),
        .whatIsYourPhoneNumber : QuestionDefinition(
            messages: [
                AttributableMessage(text: "Nice to meet you, %@", attributeNames: ["user_name"]),
                AttributableMessage(text: "What is your phone number?", attributeNames: [])
            ],
            responseHint: "0505432123",
            responseInput: .phone,
            responseAttributeName: "phone_number"
        ),
        .doYouAgreeToServiceTerms : QuestionDefinition(
            messages: [
                AttributableMessage(text: "Do you agree to our terms of service?", attributeNames: [])
            ],
            responseHint: nil,
            responseInput: .selection(options: ["No", "Yes"]),
            responseAttributeName: "tos_agreement"
        ),
        .whatToDoNowThatYouFinished : QuestionDefinition(
            messages: [
                AttributableMessage(text: "Thanks", attributeNames: []),
                AttributableMessage(text: "This is your last step", attributeNames: []),
                AttributableMessage(text: "What do you want to do now?", attributeNames: [])
            ],
            responseHint: nil,
            responseInput: .selection(options: ["Restart", "Exit"]),
            responseAttributeName: "should_restart"
        )
    ],
    endResponse: [
        AttributableMessage(text: "Bye bye!", attributeNames: [])
    ]
)


struct Chatbot {
    enum ChatbotError: Error {
        case invalidQuestioningCourse
        case unkownQuestion(BotQuestion)
    }
    
    private let questionnaire: Questionnaire
    private var attributes: [String : String] = [:]
    
    init(questionnaire: Questionnaire, botName: String) {
        self.questionnaire = questionnaire
        attributes["bot_name"] = botName
    }
    
    var initialQuestion: BotQuestion {
        return questionnaire.initialQuestion
    }
    
    func getQuestion(after question: BotQuestion?) throws -> BotQuestion? {
        guard let question = question, let nextQuestion = questionnaire.questionCourse[question] else {
            throw ChatbotError.invalidQuestioningCourse
        }
        return nextQuestion
    }
    
    func render(question: BotQuestion) throws -> MessageResponse {
        let questionDefinition = try getDefinition(for: question)
        
        return MessageResponse(
            botQuestion: question,
            messages: formatMessages(for: questionDefinition),
            messageFieldPlaceholder: questionDefinition.responseHint,
            inputType: questionDefinition.responseInput,
            endChat: false
        )
    }
    
    mutating func processAnswer(message: String, for question: BotQuestion) throws {
        let questionDefinition = try getDefinition(for: question)
        guard let attributeName = questionDefinition.responseAttributeName else {
            return
        }
        
        attributes[attributeName] = message
    }
    
    private func getDefinition(for question: BotQuestion) throws -> QuestionDefinition {
        guard let questionDefinition = questionnaire.questionDefinitions[question] else {
            throw ChatbotError.unkownQuestion(question)
        }
        return questionDefinition
    }
    
    private func formatMessages(for question: QuestionDefinition) -> [String] {
        return question.messages.map({ attributableMessage -> String in
            let attributeValues = attributableMessage.attributeNames.compactMap({ self.attributes[$0] })
            return attributableMessage.format(with: attributeValues)
        })
    }
}


var welcomeBot = Chatbot(questionnaire: welcomeQuestionnaire, botName: "Avihu")


struct NotImplementedError: Error {}


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
    
    private func answerQuestion(lastQuestion: BotQuestion, answer message: String) -> Result<MessageResponse, Error> {
        do {
            try welcomeBot.processAnswer(message: message, for: lastQuestion)
            if let nextQuestion = try welcomeBot.getQuestion(after: lastQuestion) {
                let messageResponse = try welcomeBot.render(question: nextQuestion)
                return .success(messageResponse)
            } else {
                return .failure(NotImplementedError())
            }
        } catch {
            return .failure(error)
        }
    }
}
