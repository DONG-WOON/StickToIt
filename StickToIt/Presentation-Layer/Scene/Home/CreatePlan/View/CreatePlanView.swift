//
//  CreatePlanView.swift
//  StickToIt
//
//  Created by 서동운 on 10/3/23.
//

import UIKit
import RxSwift
import RxCocoa

protocol CalendarButtonProtocol: AnyObject {
    func endDateSettingButtonDidTapped()
}

final class CreatePlanView: UIScrollView {
    
    weak var buttonDelegate: CalendarButtonProtocol?
    
    let planNameLabel: UILabel = {
        let view = UILabel()
        view.text = StringKey.planName.localized()
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 17)
        return view
    }()
    
    let planNameDescriptionLabel: UILabel = {
        let view = UILabel()
        view.text = StringKey.planNameDescription.localized()
        view.textColor = .secondaryLabel
        view.font = .boldSystemFont(ofSize: 14)
        return view
    }()
    
    let planNameMaximumTextNumberLabel: UILabel = {
        let view = UILabel()
        view.text = "0 / 20"
        view.textColor = .tertiaryLabel
        view.font = .boldSystemFont(ofSize: 15)
        return view
    }()
    
    let planNameTextField: BorderedTextField = {
        let view = BorderedTextField(
            cornerRadius: 10, borderWidth: 0.5,
            borderColor: .assetColor(.accent2)
        )
        view.placeholder = StringKey.planNamePlaceholder.localized()
        view.backgroundColor = .assetColor(.accent4).withAlphaComponent(0.3)
        return view
    }()
    
    let planStartDateLabel: UILabel = {
        let view = UILabel()
        view.text = StringKey.planStartDate.localized()
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 17)
        return view
    }()
    
    let planStartDateDescriptionLabel: UILabel = {
        let view = UILabel()
        view.text = StringKey.planStartDateDescription.localized()
        view.textColor = .secondaryLabel
        view.font = .boldSystemFont(ofSize: 14)
        return view
    }()

    lazy var planStartDateSegment: UISegmentedControl = {
        let view = UISegmentedControl(items: [StringKey.today.localized(), StringKey.tomorrow.localized()])
        view.selectedSegmentIndex = 0
        view.selectedSegmentTintColor = .assetColor(.accent1)
        view.tintColor = .white
        view.backgroundColor = .assetColor(.accent4).withAlphaComponent(0.3)
        view.bordered(borderWidth: 0.5, borderColor: .assetColor(.accent1))
        
        view.setTitleTextAttributes(
            [
                .font: UIFont.boldSystemFont(ofSize: 19)
            ],
            for: .normal
        )
        
        view.setTitleTextAttributes(
            [
                .font: UIFont.boldSystemFont(ofSize: 21),
                .foregroundColor: UIColor.assetColor(.accent4)
            ],
            for: .selected
        )
        return view
    }()
    
    let planTargetPeriodLabel: UILabel = {
        let view = UILabel()
        view.text = StringKey.planTargetPeriodLabel.localized()
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 17)
        return view
    }()
    
    let planEndDateDescriptionLabel: UILabel = {
        let view = UILabel()
        view.text = StringKey.planEndDateDescriptionLabel.localized()
        view.textColor = .secondaryLabel
        view.font = .boldSystemFont(ofSize: 14)
        view.numberOfLines = 0
        
        return view
    }()

    let endDateLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.bordered(borderWidth: 0.7, borderColor: .assetColor(.accent2))
        view.innerView.text = StringKey.endDateTitle.localized()
        view.innerView.backgroundColor = .clear
        view.backgroundColor = .assetColor(.accent4).withAlphaComponent(0.3)
        view.innerView.textColor = .label
        return view
    }()
    
    lazy var endDateSettingButton: ResizableButton = {
        let button = ResizableButton(
            image: UIImage(resource: .calendar),
            symbolConfiguration: .init(scale: .large),
            tintColor: .white,
            backgroundColor: .assetColor(.accent3),
            target: self,
            action: #selector(endDateSettingButtonDidTapped)
        )
        return button
    }()
    
    let descriptionLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.text = StringKey.addPlanAlert.localized()
        view.textColor = .label
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    let createButton: UIButton = {
        let view = UIButton()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    @objc func endDateSettingButtonDidTapped() {
        buttonDelegate?.endDateSettingButtonDidTapped()
    }
    
    func update(plan: Plan) {
        planNameLabel.text = plan.name

        endDateLabel.innerView.text = StringKey.endDateTitleSetting.localized(with: " \(DateFormatter.getFullDateString(from: plan.endDate))")
    }
}

extension CreatePlanView {
    
    private func configureViews() {
        
        addSubview(planNameLabel)
        addSubview(planNameDescriptionLabel)
        addSubview(planNameTextField)
        addSubview(planNameMaximumTextNumberLabel)

        addSubview(planStartDateLabel)
        addSubview(planStartDateDescriptionLabel)
        addSubview(planStartDateSegment)

        addSubview(planTargetPeriodLabel)
        addSubview(planEndDateDescriptionLabel)
        addSubview(endDateLabel)
        
        addSubview(descriptionLabel)
        addSubview(createButton)
       
        endDateLabel.addSubview(endDateSettingButton)
    }
    
    private func setConstraints() {
        
        self.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(self.frameLayoutGuide.snp.width)
        }
        
        planNameLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        planNameDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(planNameLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentLayoutGuide).inset(20)
        }
        
        planNameMaximumTextNumberLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentLayoutGuide).inset(20)
            make.bottom.equalTo(planNameTextField.snp.top).offset(-10)
        }
        
        planNameTextField.snp.makeConstraints { make in
            make.top.equalTo(planNameDescriptionLabel.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        planStartDateLabel.snp.makeConstraints { make in
            make.top.equalTo(planNameTextField.snp.bottom).offset(40)
            make.leading.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        planStartDateDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(planStartDateLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentLayoutGuide).inset(20)
        }

        planStartDateSegment.snp.makeConstraints { make in
            make.top.equalTo(planStartDateDescriptionLabel.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
    
        planTargetPeriodLabel.snp.makeConstraints { make in
            make.top.equalTo(planStartDateSegment.snp.bottom).offset(40)
            make.leading.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        planEndDateDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(planTargetPeriodLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentLayoutGuide).inset(20)
        }
        
        endDateLabel.snp.makeConstraints { make in
            make.top.equalTo(planEndDateDescriptionLabel.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
            make.size.equalTo(planNameTextField)
        }
        
        endDateSettingButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(endDateSettingButton.snp.height)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(endDateLabel.snp.bottom).offset(40)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
            make.bottom.equalTo(contentLayoutGuide).offset(-10)
        }
    }
}
