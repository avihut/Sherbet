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
    
    var chatMessage: ChatMessage? {
        didSet {
            updateView()
        }
    }
    
    private func updateView() {
        messageLabel.text = chatMessage?.text
    }
    
    @IBOutlet private weak var messageLabel: UILabel!
}
