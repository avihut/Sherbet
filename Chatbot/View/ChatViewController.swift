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


final class ChatViewController: UIViewController {
    @IBOutlet private weak var inputArea: UIView!
    @IBOutlet private weak var chatTableView: UITableView!
    @IBOutlet private weak var inputAreaBottomConstraint: NSLayoutConstraint!
    private let keyboardObserver = UnderKeyboardObserver()
    
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
        }
    }
}
