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
        
        let token = "4EmAIn41rJozc3L5c2YAd4oBjDZ6UF34q4W5WMUKP5FpraqngmeFt866dzmE"
        
        server.startChat(withToken: token) { result in
            switch result {
            case .success(let response): XCTAssert(response.messages.first! == "Hello from chatbot!")
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
}
