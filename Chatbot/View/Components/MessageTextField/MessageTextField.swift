//
//  MessageTextField.swift
//  Chatbot
//
//  Created by Avihu Turzion on 25/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import UIKit


protocol MessageTextFieldDelegate: class {
    func process(message: String)
}


final class MessageTextField: XibView {
    enum InputMode {
        case text
        case numbers
        case phone
        case email
    }
    
    @IBOutlet private weak var textFieldView: UITextField!
    @IBOutlet private weak var buttonView: UIButton!
    
    weak var delegate: MessageTextFieldDelegate?
    
    var inputMode: InputMode = .text {
        didSet {
            updateInputMode()
        }
    }
    
    var text: String? {
        set {
            textFieldView.text = newValue
        }
        get {
            return textFieldView.text
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            textFieldView.isEnabled = isEnabled
            buttonView.isEnabled = isEnabled
        }
    }
    
    var placeholder: String {
        set {
            textFieldView.placeholder = newValue
        }
        get {
            return textFieldView.placeholder ?? ""
        }
    }
    
    func clearText() {
        text = ""
    }
    
    private var textValidator: TextValidating?
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        let isFirstResponder = super.becomeFirstResponder()
        let wasTextFieldFirstResponder = textFieldView.becomeFirstResponder()
        return isFirstResponder && wasTextFieldFirstResponder
    }
    
    @IBAction private func sendButtonTapped() {
        triggerMessageProcessing()
    }
    
    private func updateInputMode() {
        switch inputMode {
        case .text:
            textFieldView.keyboardType = .asciiCapable
            textValidator = AsciiTextValidator()
            
        case .numbers:
            textFieldView.keyboardType = .numberPad
            textValidator = NumeralTextValidator()
            
        case .phone:
            textFieldView.keyboardType = .phonePad
            textValidator = NumeralTextValidator()
            
        case .email:
            textFieldView.keyboardType = .emailAddress
            textValidator = nil
        }
    }
    
    private func triggerMessageProcessing() {
        delegate?.process(message: text ?? "")
    }
}


extension MessageTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textValidator?.isValid(text: string) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        triggerMessageProcessing()
        return true
    }
}

private protocol TextValidating {
    func isValid(text: String) -> Bool
}


private struct AsciiTextValidator: TextValidating {
    func isValid(text: String) -> Bool {
        return CharacterSet.letters.isSuperset(of: CharacterSet(charactersIn: text))
    }
}


private struct NumeralTextValidator: TextValidating {
    func isValid(text: String) -> Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: text))
    }
}
