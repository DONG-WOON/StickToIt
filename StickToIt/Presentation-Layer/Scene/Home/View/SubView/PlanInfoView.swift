//
//  PlanInfoView.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import UIKit

protocol PlanInfoViewDelegate: AnyObject {
    func trashButtonDidTapped()
}

final class PlanInfoView: UIView {
    
    weak var delegate: PlanInfoViewDelegate?
    
    private let userNameLabel: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.font = .italicSystemFont(ofSize: Const.FontSize.subTitle)
        view.numberOfLines = 1
        return view
    }()
    
    private let planNameLabel: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: Const.FontSize.title)
        view.numberOfLines = 1
        return view
    }()
    
    private let lastCertifyingDayLabel: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.font = .systemFont(ofSize: Const.FontSize.body, weight: .medium)
        view.numberOfLines = 1
        return view
    }()
    
    private lazy var trashButton = ResizableButton(
        image: UIImage(resource: .trash),
        symbolConfiguration: .init(scale: .large),
        tintColor: .assetColor(.accent2),
        backgroundColor: .clear,
        target: self,
        action: #selector(trashButtonDidTapped)
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    func update(plan: Plan) {
        self.planNameLabel.text = "⌜⛳️ \(plan.name)⌟"
        self.planNameLabel.adjustsFontSizeToFitWidth = true
        self.planNameLabel.sizeToFit()
    
        let completedDayPlans = plan.dayPlans.filter { $0.isComplete == true }
        
        if let lastDay = completedDayPlans.sorted(by: { $0.date < $1.date }).last?.date {
            let date = DateFormatter.getFullDateString(from: lastDay)
            self.lastCertifyingDayLabel.text = "최근 목표 실행일: \(date)"
        } else {
            self.lastCertifyingDayLabel.text = "최근 목표 실행일: -"
        }
    }
    
    func update(user: User?) {
        guard let userName = user?.name else { return }
        userNameLabel.text = "@ \(userName) 님의 목표"
    }
    
    @objc private func trashButtonDidTapped() {
        delegate?.trashButtonDidTapped()
    }
}

extension PlanInfoView {
    
    private func configureViews() {
        addBlurEffect(.assetColor(.accent4).withAlphaComponent(0.3))
        rounded()
        addSubviews([userNameLabel, planNameLabel, trashButton, lastCertifyingDayLabel])
    }
    
    private func setConstraints() {
        
        userNameLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(self).inset(10)
            make.trailing.equalTo(trashButton.snp.leading).offset(-10)
        }
    
        planNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(self).inset(10)
        }
        
        trashButton.snp.makeConstraints { make in
            make.width.height.equalTo(planNameLabel.snp.height)
            make.top.trailing.equalTo(self).inset(10)
        }
        
        lastCertifyingDayLabel.snp.makeConstraints { make in
            make.top.equalTo(planNameLabel.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(self).inset(10)
        }
    }
}
