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
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .init(red: 99/255, green: 125/255, blue: 227/255, alpha: 1)
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
        self.backgroundColor = .clear
        
        addSubview(percentageLabel)
        addSubview(imageView)
        addSubview(circleView)
    }
    
    private func setConstraints() {
        
        circleView.snp.makeConstraints { make in
            make.leading.equalTo(self.safeAreaLayoutGuide).inset(20)
            make.height.width.equalTo(self.snp.width).multipliedBy(0.4)
            make.centerY.equalTo(self.safeAreaLayoutGuide)
        }

        percentageLabel.snp.makeConstraints { make in
            make.center.equalTo(circleView)
            make.width.lessThanOrEqualTo(circleView).multipliedBy(0.7)
        }

        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(self.safeAreaLayoutGuide)
            make.width.height.equalTo(self.snp.width).multipliedBy(0.4)
            make.trailing.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
    }
}
