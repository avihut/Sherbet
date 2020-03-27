//
//  ChatViewController.swift
//  Chatbot
//
//  Created by Avihu Turzion on 24/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import UIKit
import UnderKeyboard


struct ChatMessage: Codable {
    enum Side: Int, Codable {
        case local = 0
        case remote = 1
    }
    
    let side: Side
    let text: String
    var isOldMessage = false
}


final class ChatViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var inputArea: MessageInputField!
    @IBOutlet private weak var inputAreaBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var chatTableView: UITableView!
    
    // MARK: Properties
    
    private let keyboardObserver = UnderKeyboardObserver()
    
    private var previousMessages: [ChatMessage] = []
    private var messages: [ChatMessage] = [] {
        didSet {
            chatTableView.reloadData()
            scrollToBottom()
        }
    }
    
    private var isBotTyping = false {
        didSet {
            chatTableView.reloadData()
            scrollToBottom()
        }
    }
    
    private var remote: RemoteChatbotServer = MockLocalChatbotServer(mockServer: ChatbotWebApp().createApp(), token: "4EmAIn41rJozc3L5c2YAd4oBjDZ6UF34q4W5WMUKP5FpraqngmeFt866dzmE")
    
    private var lastQuestion: Question?
    
    private var inputType: AnswerInputType? = .text {
        didSet {
            inputArea.inputMode = .from(answerInputType: inputType)
            if inputType != nil {
                inputArea.becomeFirstResponder()
            }
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardObserver.start()
        
        keyboardObserver.willAnimateKeyboard = { [weak self] height in
            guard let requiredSelf = self else {
                return
            }
            
            self?.inputAreaBottomConstraint.constant = height == 0 ? height : height - requiredSelf.view.safeAreaInsets.bottom
        }
        
        keyboardObserver.animateKeyboard = { [weak self] height in
            self?.view.layoutIfNeeded()
            self?.scrollToBottom()
        }
        
        inputArea.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isBotTyping = true
        remote.startChat(with: handleMessageResponse(result:))
    }
    
    // MARK: Chat View
    
    private func scrollToBottom() {
        guard messages.count > 0 else {
            return
        }
        let section = numberOfSections(in: chatTableView) - 1
        chatTableView.scrollToRow(at: IndexPath(row: messages.count - (!isBotTyping ? 1 : 0), section: section), at: .bottom, animated: true)
    }
    
    // MARK: Chat Management
    
    private func updateChat(with newMessage: MessageResponse) {
        let chatMessages = newMessage.messages.map { ChatMessage(side: .remote, text: $0) }
        
        var accumulatedDelay = 0
        for message in chatMessages {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(accumulatedDelay)) { [weak self] in
                self?.messages.append(message)
            }
            accumulatedDelay += message.text.count * 30
        }
        
        lastQuestion = newMessage.botQuestion
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(accumulatedDelay)) { [weak self] in
            self?.inputType = newMessage.inputType
            self?.inputArea.placeholder = newMessage.messageFieldPlaceholder ?? ""
            self?.saveMessages()
        }
    }
    
    private func send(message: String) {
        guard let lastQuestion = lastQuestion else {
            print("Cannot reply with no question")
            return
        }
        
        let myMessage = ChatMessage(side: .local, text: message)
        messages.append(myMessage)
        isBotTyping = true
        remote.send(answer: message, for: lastQuestion, withHandler: handleMessageResponse(result:))
    }
    
    private func saveMessages() {
        let allMessages = previousMessages + messages
        if let encodedMessages = try? JSONEncoder().encode(allMessages) {
            UserDefaults.standard.set(encodedMessages, forKey: "messages")
        }
    }
    
    private func loadMessages() {
        if let previousMessagesData = UserDefaults.standard.object(forKey: "messages") as? Data, let previousMessages = try? JSONDecoder().decode([ChatMessage].self, from: previousMessagesData) {
            self.previousMessages = previousMessages
            for i in 0..<self.previousMessages.count {
                self.previousMessages[i].isOldMessage = true
            }
            
            chatTableView.reloadData()
            scrollToBottom()
        }
    }
    
    // MARK: Remote Interaction
    
    private func handleMessageResponse(result: Result<MessageResponse, Error>) {
        isBotTyping = false
        guard case Result<MessageResponse, Error>.success(let messageResponse) = result else {
            print("Received an error.")
            return
        }
        
        updateChat(with: messageResponse)
    }
}


extension ChatViewController: UITableViewDelegate {}


extension ChatViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if previousMessages.count > 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && previousMessages.count > 0 {
            return previousMessages.count
        } else if (section == 0 && previousMessages.count == 0) || section == 1 {
            let messageCount = messages.count
            return isBotTyping ? messageCount + 1 : messageCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.section == 0 && previousMessages.count > 0 {
            let chatBubbleCell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleTableViewCell.identifier) as! ChatBubbleTableViewCell
            chatBubbleCell.chatMessage = previousMessages[indexPath.row]
            cell = chatBubbleCell
        } else if ((indexPath.section == 0 && previousMessages.count == 0) || indexPath.section == 1) && indexPath.row < messages.count {
            let chatBubbleCell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleTableViewCell.identifier) as! ChatBubbleTableViewCell
            chatBubbleCell.chatMessage = messages[indexPath.row]
            cell = chatBubbleCell
        } else if ((indexPath.section == 0 && previousMessages.count == 0) || indexPath.section == 1) && indexPath.row == messages.count {
            let typingCell = tableView.dequeueReusableCell(withIdentifier: BotTypingCell.identifier) as! BotTypingCell
            typingCell.startAnimating()
            cell = typingCell
        } else {
            fatalError("Invalid cell layout.")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && numberOfSections(in: tableView) > 1 {
            return 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        footerView.backgroundColor = .darkGray
        return footerView
    }
}


extension ChatViewController: MessageInputFieldDelegate {
    func process(message: String) {
        let inspectedMessage = MessageInspector(message: message)
        guard inspectedMessage.isValid else {
            return
        }
        
        inputArea.clearText()
        inputType = nil
        send(message: inspectedMessage.sendableMessage)
    }
}


extension MessageInputField.InputMode {
    static func from(answerInputType: AnswerInputType?) -> MessageInputField.InputMode {
        guard let answerInputType = answerInputType else {
            return .disabled
        }
        
        switch answerInputType {
        case .numeric:                return .numbers
        case .phone:                  return .phone
        case .text:                   return .text
        case .email:                  return .email
        case .selection(let options): return .selection(options: options)
        }
    }
}


private struct MessageInspector {
    let originalMessage: String
    let sendableMessage: String
    
    init(message: String) {
        originalMessage = message
        sendableMessage = Self.formatMessageForSending(message)
    }
    
    var isValid: Bool {
        return !sendableMessage.isEmpty
    }
    
    private static func formatMessageForSending(_ message: String) -> String {
        return message.trimmingCharacters(in: .whitespaces)
    }
}
