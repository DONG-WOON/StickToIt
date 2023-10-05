//
//  GradientCircleView.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import UIKit
import MKRingProgressView

class GradientCircleView: RingProgressView {
    
//    let ringProgressView = RingProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.startColor = .init(red: 95/255, green: 193/255, blue: 220/255, alpha: 1)
        self.endColor = .systemIndigo
        self.ringWidth = 20
        self.progress = 0.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate() {
        UIView.animate(withDuration: 1) {
            self.progress = 0.9
        }
    }
}

//class GradientCircleView: UIView, CAAnimationDelegate {
//
//    let gradientLayer: CAGradientLayer = CAGradientLayer()
//
//    var startAngle: CGFloat =  (3 / 2 * .pi)
//    lazy var endAngle: CGFloat = startAngle + (5 / 2 * .pi)
//
//    override func draw(_ rect: CGRect) {
//
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//
//        let animation = CABasicAnimation(keyPath: "strokeEnd")
//
//        self.gradientLayer.colors = [UIColor.blue.cgColor, UIColor.cyan.cgColor]
//        self.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
//        self.gradientLayer.endPoint = CGPoint(x: 0.0, y: 0)
//        self.gradientLayer.type = .conic
//        self.gradientLayer.frame = rect
//        self.layer.addSublayer(self.gradientLayer)
//
//        animation.fromValue = 0
//        animation.toValue = 1
//        animation.duration = 1
//        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//        animation.delegate = self
//
//        let path = UIBezierPath(arcCenter: center, radius: 60, startAngle: startAngle, endAngle: endAngle - (.pi / 2), clockwise: true)
//        let sliceLayer = CAShapeLayer()
//        sliceLayer.path = path.cgPath
//        sliceLayer.fillColor = nil
//        sliceLayer.lineCap = .round
//        sliceLayer.strokeColor = UIColor.black.cgColor
//        sliceLayer.lineWidth = 20
//        sliceLayer.strokeEnd = 1
//        sliceLayer.add(animation, forKey: animation.keyPath)
//
//        self.layer.mask = sliceLayer
//    }
//}
//
//class GradientCircleView: UIView {
//    var startColor: UIColor = .white
//    var endColor: UIColor = .blue
//    var lineWidth:  CGFloat = 20
//
//    private let gradientLayer: CAGradientLayer = {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.type = .conic
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
//        return gradientLayer
//    }()
//
//    override init(frame: CGRect = .zero) {
//        super.init(frame: frame)
//
//        configure()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        configure()
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        updateGradient()
//    }
//}
//
//private extension GradientCircleView {
//    func configure() {
//        layer.addSublayer(gradientLayer)
//    }
//
//    func updateGradient() {
//        gradientLayer.frame = bounds
//        gradientLayer.colors = [startColor, endColor].map { $0.cgColor }
//
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
//        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        let mask = CAShapeLayer()
//        mask.fillColor = UIColor.clear.cgColor
//        mask.strokeColor = UIColor.white.cgColor
//        mask.lineWidth = lineWidth
//        mask.path = path.cgPath
//        gradientLayer.mask = mask
//    }
//}
