//
//  ChatViewController.swift
//  Chatbot
//
//  Created by Avihu Turzion on 24/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation
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
    
    @IBOutlet private weak var inputArea: UIView!
    
    @IBOutlet private weak var bottomFill: UIView!
    
    @IBOutlet private weak var chatTableView: UITableView!
    @IBOutlet private weak var inputAreaBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var selectionContainer: UIView!
    
    @IBOutlet private weak var leftResponseButton: UIButton!
    @IBOutlet private weak var rightResponseButton: UIButton!
    
    @IBOutlet private weak var textFieldContainer: UIView!
    
    @IBOutlet private weak var messageTextField: UITextField!
    @IBOutlet private weak var sendMessageButton: UIButton!
    
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
    
    private let chatToken = "4EmAIn41rJozc3L5c2YAd4oBjDZ6UF34q4W5WMUKP5FpraqngmeFt866dzmE"
    private var remote: RemoteChatbotServer = MockLocalChatbotServer(mockServer: ChatbotWebApp().createApp())
    
    private var lastQuestion: Question?
    
    private var inputType: AnswerInputType? = .text {
        didSet {
            updateInputView()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disableInputView()
        loadMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isBotTyping = true
        remote.startChat(withToken: chatToken, withHandler: handleMessageResponse(result:))
    }
    
    // MARK: Actions
    
    @IBAction private func sendMessageTapped() {
        guard let text = messageTextField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else {
            return
        }
        
        messageTextField.text = ""
        send(message: text)
    }
    
    @IBAction func selectionButtonTapped(_ sender: UIButton) {
        guard let message = sender.title(for: .normal) else {
            print("Button unexpectedly doesn't have title.")
            return
        }
        
        send(message: message)
    }
    
    // MARK: Input View Management
    
    private func updateInputView() {
        if let inputType = inputType {
            switch inputType {
            case .numeric:
                showTextField()
                update(keyboardType: .numberPad)
                
            case .phone:
                showTextField()
                update(keyboardType: .phonePad)
                
            case .text:
                showTextField()
                update(keyboardType: .asciiCapable)
                
            case .email:
                showTextField()
                update(keyboardType: .emailAddress)
                
            case .selection(let options):
                showSelectionButtons(with: options)
            }
        } else {
            disableInputView()
        }
    }
    
    private func update(keyboardType: UIKeyboardType) {
        messageTextField.keyboardType = keyboardType
        messageTextField.reloadInputViews()
    }
    
    private func disableInputView() {
        showTextField(focus: false)
        messageTextField.placeholder = ""
        messageTextField.isEnabled = false
        sendMessageButton.isEnabled = false
    }
    
    private func showTextField(focus: Bool = true) {
        textFieldContainer.isHidden = false
        selectionContainer.isHidden = true
        
        if focus {
            messageTextField.isEnabled = true
            sendMessageButton.isEnabled = true
            messageTextField.becomeFirstResponder()
        }
    }
    
    private func showSelectionButtons(with options: [String]) {
        textFieldContainer.isHidden = true
        selectionContainer.isHidden = false
        
        messageTextField.resignFirstResponder()
        
        leftResponseButton.setTitle(options[0], for: .normal)
        rightResponseButton.setTitle(options[1], for: .normal)
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
            self?.messageTextField.placeholder = newMessage.messageFieldPlaceholder
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
        disableInputView()
        
        isBotTyping = true
        
        remote.send(answer: message, for: lastQuestion, withToken: chatToken, withHandler: handleMessageResponse(result:))
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
