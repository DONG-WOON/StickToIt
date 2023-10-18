//
//  HomeEmptyView.swift
//  StickToIt
//
//  Created by 서동운 on 10/18/23.
//

import UIKit

protocol CreatePlanButtonDelegate: AnyObject {
    func tapButton()
}

final class HomeEmptyView: UIView {
    
    weak var delegate: CreatePlanButtonDelegate?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 추가한 계획이 없습니다."
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: FontSize.title)
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "지금 당장 계획을 추가해보세요!!"
        label.font = .systemFont(ofSize: FontSize.description)
        return label
    }()
    
    lazy var goToCreatePlanButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .assetColor(.accent2)
        configuration.baseForegroundColor = .white
        configuration.title = "계획 생성하기"
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var new = attr
            new.font = UIFont.boldSystemFont(ofSize: FontSize.body)
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
        delegate?.tapButton()
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
            make.centerY.equalTo(self).offset(-50)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.centerX.equalTo(self)
        }
        goToCreatePlanButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(15)
            make.centerX.equalTo(self)
        }
    }
}
