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
    
    func setDefaultGradient() {
        self.setGradient(
            color1: .init(red: 95/255, green: 193/255, blue: 220/255, alpha: 1).withAlphaComponent(0.5),
            color2: .systemIndigo.withAlphaComponent(0.6),
            startPoint: .init(x: 1, y: 0),
            endPoint: .init(x: 1, y: 1)
        )
    }
}

extension UIView {
    
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    convenience init(backgroundColor: UIColor) {
        self.init()
        
        self.backgroundColor = backgroundColor
    }
    
    convenience init(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        self.init()

        self.bordered(cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor)
    }
    
    func bordered(cornerRadius: CGFloat = 5, borderWidth: CGFloat, borderColor: UIColor? = nil) {
        self.rounded(cornerRadius: cornerRadius)
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
    }
    
    func rounded(cornerRadius: CGFloat = 5) {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
    }
}

