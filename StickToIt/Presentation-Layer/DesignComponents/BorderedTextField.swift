//
//  BorderedTextField.swift
//  StickToIt
//
//  Created by 서동운 on 10/3/23.
//

import UIKit

final class BorderedTextField: BorderedView<UITextField> {
    
    var placeholder: String? {
        get { innerView.placeholder }
        set { innerView.placeholder = newValue }
    }
    
    var textAlignment: NSTextAlignment {
        get { innerView.textAlignment }
        set { innerView.textAlignment = newValue }
    }
   
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
