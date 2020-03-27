//
//  MessageSelectionField.swift
//  Chatbot
//
//  Created by Avihu Turzion on 25/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import UIKit


protocol MessageSelectionFieldDelegate: class {
    func process(message: String)
}


final class MessageSelectionField: XibView {
    @IBOutlet private weak var selectionButtonsStackView: UIStackView!
    
    weak var delegate: MessageSelectionFieldDelegate?
    
    var options: [String] = [] {
        didSet {
            populateOptions()
        }
    }
    
    private func populateOptions() {
        clearButtons()
        options.forEach { option in
            let button = createSelectionButton(saying: option)
            selectionButtonsStackView.addArrangedSubview(button)
            button.heightAnchor.constraint(equalTo: selectionButtonsStackView.heightAnchor, multiplier: 0.8).isActive = true
            button.layer.cornerRadius = selectionButtonsStackView.frame.height * 0.4
        }
    }
    
    private func clearButtons() {
        selectionButtonsStackView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func createSelectionButton(saying text: String) -> UIButton {
        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        button.addTarget(self, action: #selector(optionButtonTapped(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc private func optionButtonTapped(sender button: UIButton) {
        delegate?.process(message: button.title(for: .normal) ?? "")
    }
}
