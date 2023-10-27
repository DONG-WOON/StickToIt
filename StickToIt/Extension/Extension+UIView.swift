//
//  Extension+UIView.swift
//  StickToIt
//
//  Created by 서동운 on 10/1/23.
//

import UIKit


// MARK: Identifier
extension UIView {
    static var identifier: String {
        return String(describing: Self.self)
    }
}

// MARK: Initialize
extension UIView {
    
    convenience init(backgroundColor: UIColor) {
        self.init()
        
        self.backgroundColor = backgroundColor
    }
    
    convenience init(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        self.init()
        
        self.bordered(cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor)
    }
}

// MARK: Functions
extension UIView {
    
    func bordered(cornerRadius: CGFloat = 10, borderWidth: CGFloat, borderColor: UIColor? = nil) {
        self.rounded(cornerRadius: cornerRadius)
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
    }
    
    func rounded(cornerRadius: CGFloat = 10) {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
    }
    
    func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
    
    func addBlurEffect(_ backgroundColor: UIColor = .systemBackground) {
        let visualEffectView = UIVisualEffectView(
            effect: UIBlurEffect(
                style: .light
            )
        )
        self.backgroundColor = backgroundColor
        self.addSubview(visualEffectView)
        
        visualEffectView.frame = self.frame
        self.addSubview(visualEffectView)
    }
}

