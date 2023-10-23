//
//  HomeView.swift
//  StickToIt
//
//  Created by 서동운 on 10/18/23.
//

import UIKit

final class HomeView: UIView {
    
    private lazy var planInfoView = PlanInfoView()
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
//        homeAchievementView.setProgress(progress)
    }
    
    func update(user: User?) {
        planInfoView.update(user: user)
    }
    
    func update(plan: Plan) {
        planInfoView.update(plan: plan)
    }
    
    func setDelegate(_ delegate: PlanSettingButtonDelegate) {
        planInfoView.delegate = delegate
    }
}

extension HomeView: BaseViewConfigurable {
    
    func configureViews() {
        backgroundColor = .clear
        addSubview(collectionView)
        addSubview(planInfoView)
    }
    
    func setConstraints() {
        
        planInfoView.snp.makeConstraints { make in
            make.bottom.equalTo(collectionView.snp.top).offset(-15)
            make.width.equalTo(safeAreaLayoutGuide).multipliedBy(0.85)
            make.top.equalTo(safeAreaLayoutGuide).inset(20)
            make.centerX.equalTo(safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
    }
}
