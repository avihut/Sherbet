//
//  chatBubbleTableViewCell.swift
//  Chatbot
//
//  Created by Avihu Turzion on 24/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation
import UIKit

final class ChatBubbleTableViewCell: UITableViewCell {
    static let identifier = "chatBubbleCell"
    
    @IBOutlet private weak var bubbleView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private var leftBoundConstraints: [NSLayoutConstraint]!
    @IBOutlet private var rightBoundConstraints: [NSLayoutConstraint]!
    
    var chatMessage: ChatMessage? {
        didSet {
            updateView()
        }
    }
    
    private func updateView() {
        guard let chatMessage = chatMessage else {
            return
        }
        
        messageLabel.text = chatMessage.text
        switch chatMessage.side {
        case .local:
            setRightBound()
            setLocalTheme()
            
        case .remote:
            setLeftBound()
            setRemoteTheme()
        }
        
        if chatMessage.isOldMessage {
            backgroundColor = UIColor(red: 245 / 256, green: 245 / 256, blue: 245 / 256, alpha: 1.0)
        } else {
            backgroundColor = .white
        }
    }
    
    private func setLeftBound() {
        rightBoundConstraints.forEach { $0.isActive = false }
        leftBoundConstraints.forEach { $0.isActive = true }
    }
    
    private func setRightBound() {
        rightBoundConstraints.forEach { $0.isActive = true }
        leftBoundConstraints.forEach { $0.isActive = false }
    }
    
    private func setLocalTheme() {
        bubbleView.backgroundColor = UIColor(red: 74 / 256, green: 74 / 256, blue: 74 / 256, alpha: 1.0)
        messageLabel.textColor = .white
    }
    
    private func setRemoteTheme() {
        bubbleView.backgroundColor = UIColor(red: 236 / 256, green: 236 / 256, blue: 236 / 256, alpha: 1.0)
        messageLabel.textColor = .black
    }
}
