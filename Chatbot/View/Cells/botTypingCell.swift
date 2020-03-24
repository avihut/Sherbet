//
//  botTypingCell.swift
//  Chatbot
//
//  Created by Avihu Turzion on 24/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import UIKit
import SwiftGifOrigin


final class BotTypingCell: UITableViewCell {
    static let identifier = "botTypingCell"
    
    @IBOutlet private weak var typingImageView: UIImageView!
    
    func startAnimating() {
        typingImageView.image = UIImage.gif(name: "typing")
    }
}
