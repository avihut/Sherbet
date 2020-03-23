//
//  Questionnaire.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


enum Question: Int, Codable {
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
    let initialQuestion: Question
    let questionCourse: [Question : Question?]
    let questionDefinitions: [Question : QuestionDefinition]
    let endResponse: [AttributableMessage]
}
