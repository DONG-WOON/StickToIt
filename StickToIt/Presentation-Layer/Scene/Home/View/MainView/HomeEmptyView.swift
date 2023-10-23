//
//  HomeEmptyView.swift
//  StickToIt
//
//  Created by 서동운 on 10/18/23.
//

import UIKit

protocol CreatePlanButtonDelegate: AnyObject {
    func createPlan()
}

final class HomeEmptyView: UIView {
    
    weak var delegate: CreatePlanButtonDelegate?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "목표가 아직 없어요."
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 0
//        label.adjustsFontSizeToFitWidth = true
        label.font = .boldSystemFont(ofSize: FontSize.title)
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "지금 당장 작심삼일 목표를 추가해보세요!!"
        label.font = .systemFont(ofSize: FontSize.body)
        return label
    }()
    
    lazy var goToCreatePlanButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .assetColor(.accent2)
        configuration.image = UIImage(named: "Placeholder")
//        configuration.preferredSymbolConfigurationForImage = .init(scale: .small)
        configuration.imagePlacement = .top
        configuration.imagePadding = 10
        configuration.baseForegroundColor = .white
        configuration.title = "목표 생성하기"
        
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var new = attr
            new.font = UIFont.boldSystemFont(ofSize: 23)
            return new
        }
        
        let button = UIButton(configuration: configuration)
        button.addTarget(
            self,
            action: #selector(goToCreatePlanButtonDidTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureViews()
        setConstraints()
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func goToCreatePlanButtonDidTapped() {
        delegate?.createPlan()
    }
    
    func startAnimation() {
        UIView.animate(withDuration: 1.1, delay: 0.5, options: [.curveEaseInOut, .autoreverse, .allowUserInteraction, .repeat]) {
            self.goToCreatePlanButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            self.goToCreatePlanButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }
    
    func stopAnimation() {
        UIView.animate(withDuration: 0) {
            self.goToCreatePlanButton.transform = .identity
        }
    }
}

extension HomeEmptyView: BaseViewConfigurable {
    
    func configureViews() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(goToCreatePlanButton)
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-15)
            make.width.lessThanOrEqualTo(self).multipliedBy(0.7)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
        
        goToCreatePlanButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(15)
            make.centerX.equalTo(self)
        }
    }
}
