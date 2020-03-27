//
//  XibView.swift
//  Chatbot
//
//  Created by Avihu Turzion on 25/03/2020.
//  Copyright © 2020 Avihu Turzion. All rights reserved.
//

import UIKit


class XibView: UIView {
    override required init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    // Override this to get code running while the view is initializing.
    func viewWillInitialize() {}
    
    // Override this if the name of the Xib file is different than the class name.
    var xibName: String?
    
    private func unifiedInit() {
        setupXib()
    }
    
    private func setupXib() {
        let xibName = String(describing: type(of: self))
        let viewsInXib = Bundle(for: type(of: self)).loadNibNamed(xibName, owner: self, options: nil)
        guard let view = viewsInXib?.first as? UIView else {
            return
        }
        
        view.addAndPin(to: self)
        view.backgroundColor = .clear
        
        viewWillInitialize()
    }
}
