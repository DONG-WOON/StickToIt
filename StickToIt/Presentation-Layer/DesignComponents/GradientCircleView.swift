//
//  GradientCircleView.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import UIKit
import MKRingProgressView

class GradientCircleView: RingProgressView {
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: FontSize.body)
        label.textColor = .assetColor(.black)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundRingColor = .assetColor(.accent3).withAlphaComponent(0.8)
        self.startColor = .assetColor(.accent2)
        self.endColor = .assetColor(.accent1)
        self.ringWidth = 20
        self.progress = 0.0
        
        self.addSubview(percentageLabel)
        
        percentageLabel.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.width.lessThanOrEqualTo(self).multipliedBy(0.5)
        }
    }
    
    func setProgress(_ progress: Double) {
        self.progress = progress
        
        let percentage = Int(progress * 100)
        percentageLabel.text = "목표 달성률\n\(percentage)%"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
