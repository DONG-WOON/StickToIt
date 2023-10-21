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
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .assetColor(.black)
        label.textAlignment = .center
        return label
    }()
    
    let circleView = GradientCircleView(frame: .zero)
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    func setProgress(_ progress: Double) {
        let percentage = Int(progress * 100)
        percentageLabel.text = "\(percentage)%"
        circleView.setProgress(progress)
        
        switch percentage {
        case 0:
            imageView.image = UIImage(named: "lets-go")
        case 1..<50:
            imageView.image = UIImage(named: "great")
        case 50...:
            imageView.image = UIImage(named: "awesome")
        default:
            break
        }
    }
}

extension AchievementView {
    
    private func configureViews() {
        self.addBlurEffect(.assetColor(.accent4).withAlphaComponent(0.3))
        self.rounded(cornerRadius: 20)
        addSubview(percentageLabel)
        addSubview(imageView)
        addSubview(circleView)
    }
    
    private func setConstraints() {
        let spacing = 20.0
        
        circleView.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(self).inset(spacing)
            make.height.equalTo(circleView.snp.width)
        }

        percentageLabel.snp.makeConstraints { make in
            make.center.equalTo(circleView)
            make.width.lessThanOrEqualTo(circleView).multipliedBy(0.5)
        }

        imageView.snp.makeConstraints { make in
            make.trailing.top.bottom.equalTo(self).inset(spacing)
            make.height.equalTo(imageView.snp.width)
        }
    }
}
