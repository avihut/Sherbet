//
//  UIViewExtensions.swift
//  Chatbot
//
//  Created by Avihu Turzion on 25/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import UIKit


extension UIView {
    func addAndPin(to superView: UIView) {
        superView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo:      superView.topAnchor,      constant: 0).isActive = true
        bottomAnchor.constraint(equalTo:   superView.bottomAnchor,   constant: 0).isActive = true
        leadingAnchor.constraint(equalTo:  superView.leadingAnchor,  constant: 0).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
    }
}
