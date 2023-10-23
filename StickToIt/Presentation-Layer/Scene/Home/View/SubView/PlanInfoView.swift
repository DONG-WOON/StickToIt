//
//  PlanInfoView.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import UIKit

protocol PlanSettingButtonDelegate: AnyObject {
    func goToPlanSetting()
}

final class PlanInfoView: UIView {
    
    weak var delegate: PlanSettingButtonDelegate?
    
    private let userNameLabel: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.font = .italicSystemFont(ofSize: FontSize.subTitle)
        view.numberOfLines = 1
        return view
    }()
    
    private let planNameLabel: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: FontSize.title)
        view.numberOfLines = 1
        return view
    }()
    
    private let lastCertifyingDayLabel: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.font = .systemFont(ofSize: FontSize.body, weight: .medium)
        view.numberOfLines = 1
        return view
    }()
    
    private lazy var settingButton = ResizableButton(
        image: UIImage(resource: .gear),
        symbolConfiguration: .init(scale: .large),
        tintColor: .assetColor(.accent2),
        backgroundColor: .clear,
        target: self,
        action: #selector(goToSettingButton)
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
//    func setProgress(_ progress: Double) {
//        let percentage = Int(progress * 100)
//        percentageLabel.text = "\(percentage)%"
//        circleView.setProgress(progress)
//
//        switch percentage {
//        case 0:
//            imageView.image = UIImage(named: "lets-go")
//        case 1..<50:
//            imageView.image = UIImage(named: "great")
//        case 50...:
//            imageView.image = UIImage(named: "awesome")
//        default:
//            break
//        }
//    }
    
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
    
    @objc private func goToSettingButton() {
        delegate?.goToPlanSetting()
    }
}

extension PlanInfoView {
    
    private func configureViews() {
        addBlurEffect(.assetColor(.accent4).withAlphaComponent(0.3))
        rounded()
        addSubviews([userNameLabel, planNameLabel, settingButton, lastCertifyingDayLabel])
    }
    
    private func setConstraints() {
        
        userNameLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(self).inset(10)
            make.trailing.equalTo(settingButton.snp.leading).offset(-10)
        }
    
        planNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(self).inset(10)
        }
        
        settingButton.snp.makeConstraints { make in
            make.width.height.equalTo(planNameLabel.snp.height)
            make.top.trailing.equalTo(self).inset(10)
        }
        
        lastCertifyingDayLabel.snp.makeConstraints { make in
            make.top.equalTo(planNameLabel.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(self).inset(10)
        }
        
        
//        circleView.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(10)
//            make.leading.bottom.equalTo(self).inset(20)
//            make.height.width.equalTo(self.snp.width).multipliedBy(0.3)
//        }

//        imageView.snp.makeConstraints { make in
//            make.trailing.top.bottom.equalTo(self).inset(spacing)
//            make.height.equalTo(imageView.snp.width)
//        }
    }
}
