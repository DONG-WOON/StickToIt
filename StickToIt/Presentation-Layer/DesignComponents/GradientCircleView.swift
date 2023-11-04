//
//  GradientCircleView.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import UIKit
import MKRingProgressView

class GradientCircleView: RingProgressView {
    
    let percentageTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: Const.FontSize.body)
        label.textColor = .label
        label.text = "Achievement".localized()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: Const.FontSize.body)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundRingColor = .assetColor(.accent3).withAlphaComponent(0.8)
        self.startColor = .assetColor(.accent2)
        self.endColor = .assetColor(.accent1)
        self.ringWidth = 20
        
        self.addSubviews([percentageTitleLabel, percentageLabel])
        
        percentageTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.centerY)
            make.centerX.equalTo(self)
            make.width.lessThanOrEqualTo(self).multipliedBy(0.5)
        }
        
        percentageLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.centerY)
            make.centerX.equalTo(self)
            make.width.lessThanOrEqualTo(self).multipliedBy(0.5)
        }
    }
    
    func setProgress(_ progress: Double) {
        UIView.animate(withDuration: 1, delay: 1, options: [.allowAnimatedContent, .curveEaseInOut]) {
            self.progress = 0.0
        } completion: { _ in
            self.progress = progress
        }

        let percentage = Int(progress * 100)
        percentageLabel.text = "\(percentage)%"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
