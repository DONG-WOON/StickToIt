//
//  GradientCircleView.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import UIKit
import MKRingProgressView

class GradientCircleView: RingProgressView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundRingColor = .assetColor(.accent3).withAlphaComponent(0.8)
        self.startColor = .assetColor(.accent2)
        self.endColor = .assetColor(.accent1)
        self.ringWidth = 20
        self.progress = 0.0
    }
    
    func setProgress(_ progress: Double) {
        self.progress = progress
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
