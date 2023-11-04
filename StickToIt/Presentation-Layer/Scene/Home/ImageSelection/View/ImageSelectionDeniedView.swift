//
//  ImageSelectionDeniedView.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import UIKit
protocol SettingButtonDelegate: AnyObject {
    func settingButtonDidTapped()
}

final class ImageSelectionDeniedView: UIView {
    
    weak var delegate: SettingButtonDelegate?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = StringKey.photoPermission.localized()
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = StringKey.photoSettingMessage.localized()
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    lazy var goToSettingButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .assetColor(.accent2)
        configuration.baseForegroundColor = .white
        configuration.title = StringKey.goToPhotoSetting.localized()
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.backgroundColor = .clear
        
        configureViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(goToSettingButton)
        
        goToSettingButton.addTarget(
            self,
            action: #selector(goToSettingButtonDidTapped),
            for: .touchUpInside
        )
    }
    
    private func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-50)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.centerX.equalTo(self)
        }
        goToSettingButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(15)
            make.centerX.equalTo(self)
        }
    }
    @objc private func goToSettingButtonDidTapped() {
        delegate?.settingButtonDidTapped()
    }
}
