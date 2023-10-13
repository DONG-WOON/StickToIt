//
//  BlurEffectView.swift
//  StickToIt
//
//  Created by 서동운 on 10/13/23.
//

import UIKit

final class BlurEffectView: UIView {
    
    private let visualEffectView = UIVisualEffectView(
        effect: UIBlurEffect(
            style: .light
        )
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
extension BlurEffectView: BaseViewConfigurable {
    
    func configureViews() {
        backgroundColor = .black.withAlphaComponent(0.3)
        
        self.addSubview(visualEffectView)
    }
    
    func setConstraints() {
        visualEffectView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}
