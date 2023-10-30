//
//  ImageSelectionView.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import UIKit

final class ImageSelectionView: UIView, BaseViewConfigurable {
    
    weak var delegate: SettingButtonDelegate?
    
    lazy var goSettingButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .assetColor(.accent2)
        configuration.baseForegroundColor = .white
        configuration.title = StringKey.goToPhotoSetting.localized()
        configuration.titleAlignment = .center
        let button = UIButton(configuration: configuration)
        
        button.addTarget(self, action: #selector(goToSettingButtonDidTapped),
                         for: .touchUpInside)
        return button
    }()
    
    let collectionView = ImageCollectionView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideGoSettingButton(isHidden: Bool) {
        goSettingButton.isHidden = isHidden
        if isHidden {
            goSettingButton.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
    }
    
    func configureViews() {
        backgroundColor = backgroundColor
        
        addSubview(goSettingButton)
        addSubview(collectionView)
    }
    
    func setConstraints() {
        goSettingButton.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(2)
            make.centerX.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(30)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(goSettingButton.snp.bottom).offset(2)
            make.horizontalEdges.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    @objc func goToSettingButtonDidTapped() {
        delegate?.settingButtonDidTapped()
    }
}

final class ImageCollectionView: UICollectionView {

    init() {
        super.init(
            frame: .zero,
            collectionViewLayout: Self.createLayout()
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageCollectionView {
    
    static func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex, environment) in

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1 / 2),
                heightDimension: .fractionalWidth(1 / 2)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1 / 2)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 2
            )
            
            group.interItemSpacing = .fixed(5.0)
            
            let section = NSCollectionLayoutSection(group: group)
            
            let spacing = 10.0
            let sectionInset = NSDirectionalEdgeInsets(
                top: spacing,
                leading: spacing,
                bottom: spacing,
                trailing: spacing
            )
            
            section.contentInsets = sectionInset
            
            return section
        }
        return layout
    }
}
