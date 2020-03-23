//
//  ChatViewController.swift
//  Chatbot
//
//  Created by Avihu Turzion on 24/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import Foundation
import UIKit


final class ChatViewController: UIViewController {
    @IBOutlet private weak var inputArea: UIView!
    @IBOutlet private weak var chatTableView: UITableView!
    @IBOutlet private weak var inputAreaBottomConstraint: NSLayoutConstraint!
}
