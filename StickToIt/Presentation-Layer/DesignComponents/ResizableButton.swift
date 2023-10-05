//
//  ResizableButton.swift
//  StickToIt
//
//  Created by 서동운 on 10/1/23.
//

import UIKit

final class ResizableButton: UIButton {
    
    // MARK: Default
    convenience init(
        title: String? = nil,
        image: UIImage? = nil,
        symbolConfiguration: UIImage.SymbolConfiguration? = .init(scale: .default),
        font: UIFont? = nil,
        tintColor: UIColor?,
        backgroundColor: UIColor? = .systemBackground,
        imageAlignment: UISemanticContentAttribute? = .forceLeftToRight,
        target: Any?,
        action: Selector
    ) {
        self.init()
        
        if let symbolConfiguration {
            self.setPreferredSymbolConfiguration(
                symbolConfiguration,
                forImageIn: .normal
            )
        }
        
        if let title {
            self.setTitle(title + " ", for: .normal)
        }
        
        if let imageAlignment {
            self.semanticContentAttribute = imageAlignment
        }
        
        self.backgroundColor = backgroundColor
        self.setTitleColor(tintColor, for: .normal)
        self.titleLabel?.font = font
        self.tintColor = tintColor
        
        self.setImage(image, for: .normal)
        
        self.addTarget(target, action: action, for: .touchUpInside)
    }
}
