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


struct ChatMessage {
    enum Side {
        case local
        case remote
    }
    
    let side: Side
    let text: String
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
    
    private var messages: [ChatMessage] = [] {
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
            self?.scrollToBottom()
        }
        
        keyboardObserver.animateKeyboard = { [weak self] height in
            self?.view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disableInputView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        remote.startChat(withToken: chatToken, withHandler: handleMessageResponse(result:))
    }
    
    // MARK: Actions
    
    @IBAction private func sendMessageTapped() {
        guard let text = messageTextField.text else {
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
        chatTableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
    }
    
    // MARK: Chat Management
    
    private func updateChat(with newMessage: MessageResponse) {
        let chatMessages = newMessage.messages.map { ChatMessage(side: .remote, text: $0) }
        messages.append(contentsOf: chatMessages)
        lastQuestion = newMessage.botQuestion
        inputType = newMessage.inputType
    }
    
    private func send(message: String) {
        guard let lastQuestion = lastQuestion else {
            print("Cannot reply with no question")
            return
        }
        
        let myMessage = ChatMessage(side: .local, text: message)
        messages.append(myMessage)
        disableInputView()
        
        remote.send(answer: message, for: lastQuestion, withToken: chatToken, withHandler: handleMessageResponse(result:))
    }
    
    // MARK: Remote Interaction
    
    private func handleMessageResponse(result: Result<MessageResponse, Error>) {
        guard case Result<MessageResponse, Error>.success(let messageResponse) = result else {
            print("Received an error.")
            return
        }
        
        updateChat(with: messageResponse)
    }
}


extension ChatViewController: UITableViewDelegate {}


extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleTableViewCell.identifier) as! ChatBubbleTableViewCell
        cell.chatMessage = messages[indexPath.row]
        return cell
    }
}
