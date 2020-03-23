//
//  Chatbot.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


struct Chatbot {
    enum ChatbotError: Error {
        case invalidQuestioningCourse
        case unkownQuestion(Question)
    }
    
    private let questionnaire: Questionnaire
    private var attributes: [String : String] = [:]
    
    init(questionnaire: Questionnaire, botName: String) {
        self.questionnaire = questionnaire
        attributes["bot_name"] = botName
    }
    
    var initialQuestion: Question {
        return questionnaire.initialQuestion
    }
    
    func getQuestion(after question: Question?) throws -> Question? {
        guard let question = question, let nextQuestion = questionnaire.questionCourse[question] else {
            throw ChatbotError.invalidQuestioningCourse
        }
        
        if nextQuestion == nil && shouldRestart {
            return initialQuestion
        }
        
        return nextQuestion
    }
    
    func render(question: Question) throws -> MessageResponse {
        let questionDefinition = try getDefinition(for: question)
        
        return MessageResponse(
            botQuestion: question,
            messages: formatMessages(for: questionDefinition),
            messageFieldPlaceholder: questionDefinition.responseHint,
            inputType: questionDefinition.responseInput,
            endChat: false
        )
    }
    
    var endMessage: MessageResponse {
        return MessageResponse(
            botQuestion: nil,
            messages: format(messages: questionnaire.endResponse),
            messageFieldPlaceholder: nil,
            inputType: nil,
            endChat: true
        )
    }
    
    mutating func processAnswer(message: String, for question: Question) throws {
        let questionDefinition = try getDefinition(for: question)
        guard let attributeName = questionDefinition.responseAttributeName else {
            return
        }
        
        attributes[attributeName] = message
    }
    
    private func getDefinition(for question: Question) throws -> QuestionDefinition {
        guard let questionDefinition = questionnaire.questionDefinitions[question] else {
            throw ChatbotError.unkownQuestion(question)
        }
        return questionDefinition
    }
    
    private func formatMessages(for question: QuestionDefinition) -> [String] {
        return format(messages: question.messages)
    }
    
    private func format(messages: [AttributableMessage]) -> [String] {
        messages.map({ attributableMessage -> String in
            let attributeValues = attributableMessage.attributeNames.compactMap({ self.attributes[$0] })
            return attributableMessage.format(with: attributeValues)
        })
    }
    
    private var shouldRestart: Bool {
        guard let restartValue = attributes["should_restart"] else {
            return false
        }
        
        return restartValue == "Restart"
    }
}
