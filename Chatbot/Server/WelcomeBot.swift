//
//  WelcomeBot.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


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


var welcomeBot = Chatbot(questionnaire: welcomeQuestionnaire, botName: "Avihu")
