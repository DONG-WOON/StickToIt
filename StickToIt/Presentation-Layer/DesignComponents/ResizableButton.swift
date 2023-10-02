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
        symbolSize: CGFloat,
        font: UIFont? = nil,
        weight: UIImage.SymbolWeight = .regular,
        scale: UIImage.SymbolScale = .default,
        tintColor: UIColor,
        imageAlignment: UISemanticContentAttribute
    ) {
        self.init()
        
        self.setPreferredSymbolConfiguration(
            .init(
                pointSize: symbolSize,
                weight: weight,
                scale: scale),
            forImageIn: .normal
        )
        
        self.setImage(image, for: .normal)
        if let title {
            self.setTitle(title + " ", for: .normal)
        }
        self.setTitleColor(tintColor, for: .normal)
        self.titleLabel?.font = font
        self.tintColor = tintColor
        self.semanticContentAttribute = imageAlignment
    }
    
    // MARK: Add Action
    convenience init(
        title: String? = nil,
        image: UIImage? = nil,
        symbolSize: CGFloat,
        font: UIFont? = nil,
        weight: UIImage.SymbolWeight = .regular,
        scale: UIImage.SymbolScale = .default,
        tintColor: UIColor,
        imageAlignment: UISemanticContentAttribute = .forceLeftToRight,
        action: UIAction
    ) {
        self.init(
            title: title, image: image,
            symbolSize: symbolSize, font: font,
            weight: weight, scale: scale,
            tintColor: tintColor, imageAlignment: imageAlignment
        )
        self.addAction(action, for: .touchUpInside)
    }
    
    // MARK: Add Target
    convenience init(
        title: String? = nil,
        image: UIImage? = nil,
        symbolSize: CGFloat,
        font: UIFont? = nil,
        weight: UIImage.SymbolWeight = .regular,
        scale: UIImage.SymbolScale = .default,
        tintColor: UIColor,
        imageAlignment: UISemanticContentAttribute = .forceLeftToRight,
        target: Any?,
        action: Selector
    ) {
        self.init(
            title: title, image: image,
            symbolSize: symbolSize, font: font,
            weight: weight, scale: scale,
            tintColor: tintColor, imageAlignment: imageAlignment
        )
        self.addTarget(target, action: action, for: .touchUpInside)
    }
    
//    convenience init(
//        type: UIButton.Configuration,
//        image: UIImage? = nil,
//        title: String? = nil,
//        tintColor: UIColor,
//        buttonSize: UIButton.Configuration.Size,
//        target: Any?,
//        action: Selector
//    ) {
//        self.init()
//        
//        var configuration = type
//        configuration.title = title
//        configuration.image = image?.withTintColor(tintColor)
//        configuration.buttonSize = buttonSize
//        configuration.baseForegroundColor = tintColor
//        configuration.imagePadding = 10
//        configuration.imagePlacement = .trailing
//        
//        self.configuration = configuration
//        self.addTarget(target, action: action, for: .touchUpInside)
//        self.font
//    }
}
