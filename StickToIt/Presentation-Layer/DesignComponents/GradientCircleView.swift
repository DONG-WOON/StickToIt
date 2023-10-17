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
        self.backgroundRingColor = .black.withAlphaComponent(0.4)
        self.startColor = .init(red: 95/255, green: 193/255, blue: 220/255, alpha: 1)
        self.endColor = .systemIndigo
        self.ringWidth = 20
        self.progress = 0.0
    }
    
    func setProgress(_ progress: Double) {
        UIView.animate(withDuration: 0.7) {
            print(progress)
            self.progress = progress
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
