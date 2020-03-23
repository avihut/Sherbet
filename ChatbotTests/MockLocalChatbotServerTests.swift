//
//  ChatbotWebAppTests.swift
//  ChatbotWebAppTests
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import XCTest
@testable import Chatbot


class MockLocalChatbotServerTests: XCTestCase {
    
    private var server: MockLocalChatbotServer?
    private let token = "4EmAIn41rJozc3L5c2YAd4oBjDZ6UF34q4W5WMUKP5FpraqngmeFt866dzmE"

    override func setUp() {
        server = MockLocalChatbotServer(mockServer: ChatbotWebApp().createApp())
    }

    override func tearDown() {
        server = nil
    }
    
    func testStartChat() {
        guard let server = server else {
            fatalError("Start Chat test expected initialized mock server.")
        }
        
        server.startChat(withToken: token) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.botQuestion, BotQuestion.whatIsYourName)
                XCTAssertEqual(response.messages[0], "Hello, I am Avihu!")
                XCTAssertEqual(response.messages[1], "What is your name?")
                XCTAssertEqual(response.messageFieldPlaceholder, "Your name")
                XCTAssertEqual(response.inputType, AnswerInputType.text)
                
            case .failure(_): fatalError("Did not expect an error starting a chat.")
            }
        }
    }
    
    func testStartChatFailsWithInvalidToken() {
        guard let server = server else {
            fatalError("Start Chat test expected initialized mock server.")
        }
        
        server.startChat(withToken: "") { result in
            switch result {
            case .success(_): fatalError("Didn't expect Start Chat request to succeed with invalid token.")
            case .failure(_): break
            }
        }
    }
    
    func testFullScenario() {
        guard let server = server else {
            fatalError("Start Chat test expected initialized mock server.")
        }
        
        server.startChat(withToken: token) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.botQuestion, BotQuestion.whatIsYourName)
                XCTAssertEqual(response.messages[0], "Hello, I am Avihu!")
                XCTAssertEqual(response.messages[1], "What is your name?")
                XCTAssertEqual(response.messageFieldPlaceholder, "Your name")
                XCTAssertEqual(response.inputType, AnswerInputType.text)
                XCTAssertFalse(response.endChat)
                
            case .failure(_): fatalError("Did not expect an error starting a chat.")
            }
        }
        
        server.send(answer: "Slartibartfast", for: BotQuestion.whatIsYourName, withToken: token) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.botQuestion, BotQuestion.whatIsYourPhoneNumber)
                XCTAssertEqual(response.messages[0], "Nice to meet you, Slartibartfast")
                XCTAssertEqual(response.messages[1], "What is your phone number?")
                XCTAssertEqual(response.messageFieldPlaceholder, "0505432123")
                XCTAssertEqual(response.inputType, AnswerInputType.phone)
                XCTAssertFalse(response.endChat)
                
            case .failure(_): fatalError("Did not expect an error starting a chat.")
            }
        }
        
        server.send(answer: "0505432123", for: BotQuestion.whatIsYourPhoneNumber, withToken: token) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.botQuestion, BotQuestion.doYouAgreeToServiceTerms)
                XCTAssertEqual(response.messages[0], "Do you agree to our terms of service?")
                XCTAssertEqual(response.messageFieldPlaceholder, nil)
                XCTAssertEqual(response.inputType, AnswerInputType.selection(options: ["No", "Yes"]))
                XCTAssertFalse(response.endChat)
                
            case .failure(_): fatalError("Did not expect an error starting a chat.")
            }
        }
        
        server.send(answer: "Yes", for: BotQuestion.doYouAgreeToServiceTerms, withToken: token) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.botQuestion, BotQuestion.whatToDoNowThatYouFinished)
                XCTAssertEqual(response.messages[0], "Thanks")
                XCTAssertEqual(response.messages[1], "This is your last step")
                XCTAssertEqual(response.messages[2], "What do you want to do now?")
                XCTAssertEqual(response.messageFieldPlaceholder, nil)
                XCTAssertEqual(response.inputType, AnswerInputType.selection(options: ["Restart", "Exit"]))
                XCTAssertFalse(response.endChat)
                
            case .failure(_): fatalError("Did not expect an error starting a chat.")
            }
        }
        
        server.send(answer: "Exit", for: BotQuestion.whatToDoNowThatYouFinished, withToken: token) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.botQuestion, nil)
                XCTAssertEqual(response.messages[0], "Bye bye!")
                XCTAssertEqual(response.messageFieldPlaceholder, nil)
                XCTAssertEqual(response.inputType, nil)
                XCTAssertTrue(response.endChat)
                
            case .failure(_): fatalError("Did not expect an error starting a chat.")
            }
        }
    }
    
    func testFullScenarioWithRestart() {
        guard let server = server else {
            fatalError("Start Chat test expected initialized mock server.")
        }
        
        server.startChat(withToken: token) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.botQuestion, BotQuestion.whatIsYourName)
                XCTAssertEqual(response.messages[0], "Hello, I am Avihu!")
                XCTAssertEqual(response.messages[1], "What is your name?")
                XCTAssertEqual(response.messageFieldPlaceholder, "Your name")
                XCTAssertEqual(response.inputType, AnswerInputType.text)
                XCTAssertFalse(response.endChat)
                
            case .failure(_): fatalError("Did not expect an error starting a chat.")
            }
        }
        
        server.send(answer: "Slartibartfast", for: BotQuestion.whatIsYourName, withToken: token) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.botQuestion, BotQuestion.whatIsYourPhoneNumber)
                XCTAssertEqual(response.messages[0], "Nice to meet you, Slartibartfast")
                XCTAssertEqual(response.messages[1], "What is your phone number?")
                XCTAssertEqual(response.messageFieldPlaceholder, "0505432123")
                XCTAssertEqual(response.inputType, AnswerInputType.phone)
                XCTAssertFalse(response.endChat)
                
            case .failure(_): fatalError("Did not expect an error starting a chat.")
            }
        }
        
        server.send(answer: "0505432123", for: BotQuestion.whatIsYourPhoneNumber, withToken: token) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.botQuestion, BotQuestion.doYouAgreeToServiceTerms)
                XCTAssertEqual(response.messages[0], "Do you agree to our terms of service?")
                XCTAssertEqual(response.messageFieldPlaceholder, nil)
                XCTAssertEqual(response.inputType, AnswerInputType.selection(options: ["No", "Yes"]))
                XCTAssertFalse(response.endChat)
                
            case .failure(_): fatalError("Did not expect an error starting a chat.")
            }
        }
        
        server.send(answer: "Yes", for: BotQuestion.doYouAgreeToServiceTerms, withToken: token) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.botQuestion, BotQuestion.whatToDoNowThatYouFinished)
                XCTAssertEqual(response.messages[0], "Thanks")
                XCTAssertEqual(response.messages[1], "This is your last step")
                XCTAssertEqual(response.messages[2], "What do you want to do now?")
                XCTAssertEqual(response.messageFieldPlaceholder, nil)
                XCTAssertEqual(response.inputType, AnswerInputType.selection(options: ["Restart", "Exit"]))
                XCTAssertFalse(response.endChat)
                
            case .failure(_): fatalError("Did not expect an error starting a chat.")
            }
        }
        
        server.send(answer: "Restart", for: BotQuestion.whatToDoNowThatYouFinished, withToken: token) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.botQuestion, BotQuestion.whatIsYourName)
                XCTAssertEqual(response.messages[0], "Hello, I am Avihu!")
                XCTAssertEqual(response.messages[1], "What is your name?")
                XCTAssertEqual(response.messageFieldPlaceholder, "Your name")
                XCTAssertEqual(response.inputType, AnswerInputType.text)
                XCTAssertFalse(response.endChat)
                
            case .failure(_): fatalError("Did not expect an error starting a chat.")
            }
        }
        
        server.send(answer: "Majikthighs", for: BotQuestion.whatIsYourName, withToken: token) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.botQuestion, BotQuestion.whatIsYourPhoneNumber)
                XCTAssertEqual(response.messages[0], "Nice to meet you, Majikthighs")
                XCTAssertEqual(response.messages[1], "What is your phone number?")
                XCTAssertEqual(response.messageFieldPlaceholder, "0505432123")
                XCTAssertEqual(response.inputType, AnswerInputType.phone)
                XCTAssertFalse(response.endChat)
                
            case .failure(_): fatalError("Did not expect an error starting a chat.")
            }
        }
    }
}
