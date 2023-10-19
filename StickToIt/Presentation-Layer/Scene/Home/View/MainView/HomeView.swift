//
//  HomeView.swift
//  StickToIt
//
//  Created by 서동운 on 10/18/23.
//

import UIKit

final class HomeView: UIView {
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 28)
        view.numberOfLines = 1
        return view
    }()
    
    private lazy var homeAchievementView = AchievementView()
    let collectionView = HomeImageCollectionView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(_ progress: Double) {
        homeAchievementView.setProgress(progress)
    }
    
    func setTitleLabel(text: String) {
        self.titleLabel.text = "📌 \(text)"
    }
}

extension HomeView: BaseViewConfigurable {
    
    func configureViews() {
        backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(collectionView)
        addSubview(homeAchievementView)
    }
    
    func setConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(30)
            make.height.equalTo(30)
        }
        
        homeAchievementView.snp.makeConstraints { make in
            make.bottom.equalTo(collectionView.snp.top).offset(-10)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(30)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(self.safeAreaLayoutGuide).multipliedBy(0.3)
        }
        
        collectionView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
    }
}
