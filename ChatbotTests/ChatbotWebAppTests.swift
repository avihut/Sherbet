//
//  ChatbotWebAppTests.swift
//  ChatbotWebAppTests
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import XCTest
@testable import Chatbot

class ChatbotWebAppTests: XCTestCase {
    
    private var webAppRouter: Router?

    override func setUp() {
        webAppRouter = ChatbotWebApp().createApp()
    }

    override func tearDown() {
        webAppRouter = nil
    }
    
    func testStartChat() {
        guard let router = webAppRouter else {
            fatalError("Start Chat test expected initialized web app router.")
        }
        
        let result = router.call(endpoint: .startChat, with: "")
        switch result {
        case .success(let response): XCTAssert(response == "Hello from chatbot!")
        case .failure(_): fatalError("Did not expect an error starting a chat.")
        }
    }
}
