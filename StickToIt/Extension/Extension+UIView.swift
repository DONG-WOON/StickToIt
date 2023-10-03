//
//  Extension+UIView.swift
//  StickToIt
//
//  Created by 서동운 on 10/1/23.
//

import UIKit

extension UIView {
    func setGradient(
        color1: UIColor,
        color2: UIColor,
        startPoint: CGPoint,
        endPoint: CGPoint,
        locations: [NSNumber] = [0.0, 1.0]
    ) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.locations = locations
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = bounds
        layer.addSublayer(gradient)
    }
}

extension UIView {
    
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    func bordered(cornerRadius: CGFloat = 5, borderWidth: CGFloat, borderColor: UIColor) {
        self.rounded(cornerRadius: cornerRadius)
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
    func rounded(cornerRadius: CGFloat = 5) {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
    }
}

