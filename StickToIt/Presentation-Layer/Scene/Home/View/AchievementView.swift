//
//  AchievementView.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import UIKit

final class AchievementView: UIView {
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "25%"
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .init(red: 99/255, green: 125/255, blue: 227/255, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    let circleView = GradientCircleView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    private func configureViews() {
        self.backgroundColor = .systemBackground
        
        self.bordered(cornerRadius: 20, borderWidth: 1.5, borderColor: .init(red: 95/255, green: 193/255, blue: 220/255, alpha: 1))
        
        addSubview(percentageLabel)
        addSubview(circleView)
    }
    
    private func setConstraints() {
        circleView.snp.makeConstraints { make in
            make.leading.equalTo(self).inset(20)
            make.height.equalTo(self).multipliedBy(0.7)
            make.width.equalTo(circleView.snp.height)
            make.centerY.equalTo(self)
        }
        
        percentageLabel.snp.makeConstraints { make in
            make.center.equalTo(circleView)
            make.width.lessThanOrEqualTo(circleView).multipliedBy(0.7)
        }
    }
}
