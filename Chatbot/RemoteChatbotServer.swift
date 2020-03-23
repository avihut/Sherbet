//
//  RemoteChatbotServer.swift
//  Chatbot
//
//  Created by Avihu Turzion on 23/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation


enum ChatbotServerEndpoint: String {
    case startChat = "/start_chat"
    case send_message = ""
}


protocol RemoteChatbotServer {
    func startChat(withToken token: String, withHandler completionHandler: (Result<MessageResponse, Error>) -> ())
}


struct MockLocalChatbotServer: RemoteChatbotServer {
    enum ServerError: Error {
        case failedParsingResponse
    }
    
    private let mockServer: Router
    
    init(mockServer: Router) {
        self.mockServer = mockServer
    }
    
    func startChat(withToken token: String, withHandler completionHandler: (Result<MessageResponse, Error>) -> ()) {
        let startChatRequest = StartChatRequest(token: token)
        post(to: .startChat, request: startChatRequest, completionHandler: completionHandler)
    }
    
    private func post<Request: Encodable, Response: Decodable>(to endpoint: ChatbotServerEndpoint, request: Request, completionHandler: (Result<Response, Error>) -> ()) {
        let payload = try? JSONEncoder().encode(request)
        let payloadData = sanitize(payload: payload)
        let result = mockServer.call(endpoint: endpoint.rawValue, with: payloadData)
        
        switch result {
        case .success(let responseData):
            guard let response = try? JSONDecoder().decode(Response.self, from: responseData) else {
                completionHandler(.failure(ServerError.failedParsingResponse))
                return
            }
            completionHandler(.success(response))
            
        case .failure(let error):
            completionHandler(.failure(error))
        }
    }
    
    private func sanitize(payload: Data?) -> Data {
        let payloadData: Data
        if let payload = payload {
            payloadData = payload
        } else {
            payloadData = try! JSONEncoder().encode("{}".data(using: .utf8)!)
        }
        return payloadData
    }
}


struct StartChatRequest: Codable {
    let token: String
}

enum BotQuestion: Int, Codable {
    case whatIsYourName = 0
    case whatIsYourPhoneNumber = 1
    case doYouAgreeToServiceTerms = 2
    case whatToDoNowThatYouFinished = 3
}

enum AnswerInputType {
    case numeric
    case phone
    case text
    case email
    case selection(options: [String])
}

extension AnswerInputType: Equatable {}

extension AnswerInputType: Codable {
    enum Key: CodingKey {
        case rawValue
        case associatedValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .numeric
        case 1:
            self = .phone
        case 2:
            self = .text
        case 3:
            self = .email
        case 4:
            let options = try container.decode([String].self, forKey: .associatedValue)
            self = .selection(options: options)
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .numeric:
            try container.encode(0, forKey: .rawValue)
        case .phone:
            try container.encode(1, forKey: .rawValue)
        case .text:
            try container.encode(2, forKey: .rawValue)
        case .email:
            try container.encode(3, forKey: .rawValue)
        case .selection(let options):
            try container.encode(4, forKey: .rawValue)
            try container.encode(options, forKey: .associatedValue)
        }
    }
}

struct MessageResponse: Codable {
    let botQuestion: BotQuestion
    let messages: [String]
    let messageFieldPlaceholder: String
    let inputType: AnswerInputType
}
