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
        label.text = StringKey.emptyViewTitle.localized()
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = .boldSystemFont(ofSize: Const.FontSize.title)
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Add Plan Right Now".localized()
        label.font = .systemFont(ofSize: Const.FontSize.body)
        return label
    }()
    
    lazy var goToCreatePlanButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .assetColor(.accent2)
        button.rounded()
        button.setImage(UIImage(asset: .placeholder), for: .normal)
        
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
        UIView.animate(withDuration: 1.1, delay: 0.5, options: [.curveEaseInOut, .autoreverse, .allowUserInteraction, .repeat]) { [weak self] in
            self?.goToCreatePlanButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { [weak self] _ in
            self?.goToCreatePlanButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }
    
    func stopAnimation() {
        UIView.animate(withDuration: 0) { [weak self] in
            self?.goToCreatePlanButton.transform = .identity
        }
    }
    
    func update(nickname: String) {
        titleLabel.text = StringKey.emptyViewNicknameLabel.localized(with: "\(nickname)")
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
            make.width.equalTo(self).multipliedBy(0.4)
            make.height.equalTo(goToCreatePlanButton.snp.width)
        }
    }
}
