//
//  MessageInputField.swift
//  Chatbot
//
//  Created by Avihu Turzion on 24/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import UIKit


protocol MessageInputFieldDelegate: class {
    func process(message: String)
}


final class MessageInputField: XibView {
    enum InputMode {
        case text
        case numbers
        case phone
        case email
        case selection(options: [String])
        case disabled
    }
    
    weak var delegate: MessageInputFieldDelegate?
    
    var inputMode: InputMode = .text {
        didSet {
            updateViews()
        }
    }
    
    var placeholder: String = "" {
        didSet {
            messageTextFieldView?.placeholder = placeholder
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            messageTextFieldView?.isEnabled = isEnabled
        }
    }
    
    private var messageTextFieldView: MessageTextField?
    private var messageSelectionFieldView: MessageSelectionField?
    
    private var inputSubviewe: [UIView] {
        return [messageTextFieldView, messageSelectionFieldView].compactMap { $0 }
    }
    
    private var activeInputSubview: UIView? {
        return inputSubviewe.first
    }
    
    override func viewWillInitialize() {
        super.viewWillInitialize()
        updateViews()
    }
    
    func clearText() {
        messageTextFieldView?.clearText()
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        let isFirstResponder = super.becomeFirstResponder()
        let wasActiveInputFirstResponder = activeInputSubview?.becomeFirstResponder() ?? false
        return isFirstResponder && wasActiveInputFirstResponder
    }
    
    private func updateViews() {
        switch inputMode {
        case .text:                   switchToMessageTextField()
        case .numbers:                switchToMessageTextField()
        case .phone:                  switchToMessageTextField()
        case .email:                  switchToMessageTextField()
        case .selection(let options): switchToMessageSelectionField(with: options)
        case .disabled:
            switchToMessageTextField(disabled: true)
            placeholder = ""
        }
    }
    
    private func switchToMessageTextField(disabled: Bool = false) {
        if messageTextFieldView == nil {
            clearInputViews()
            messageTextFieldView = MessageTextField()
            messageTextFieldView?.delegate = self
            messageTextFieldView?.addAndPin(to: self)
            messageTextFieldView?.placeholder = placeholder
        }
        
        messageTextFieldView?.inputMode = .from(inputFieldMode: inputMode)
        isEnabled = !disabled
    }
    
    private func switchToMessageSelectionField(with options: [String]) {
        if messageSelectionFieldView == nil {
            clearInputViews()
            messageSelectionFieldView = MessageSelectionField()
            messageSelectionFieldView?.delegate = self
            messageSelectionFieldView?.addAndPin(to: self)
        }
        
        messageSelectionFieldView?.options = options
    }
    
    private func clearInputViews() {
        [messageTextFieldView, messageSelectionFieldView].forEach { view in
            view?.removeFromSuperview()
        }
        
        messageTextFieldView = nil
        messageSelectionFieldView = nil
    }
}

extension MessageInputField: MessageTextFieldDelegate, MessageSelectionFieldDelegate {
    func process(message: String) {
        delegate?.process(message: message)
    }
}


extension MessageTextField.InputMode {
    static func from(inputFieldMode: MessageInputField.InputMode) -> MessageTextField.InputMode {
        switch inputFieldMode {
        case .text:    return .text
        case .numbers: return .numbers
        case .phone:   return .phone
        case .email:   return .email
        default:       return .text
        }
    }
}
