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
    func calendarButtonDidTapped()
}

final class CreatePlanView: UIScrollView {
    
    weak var buttonDelegate: CalendarButtonProtocol?
    
    var selectedDays = BehaviorSubject<Set<Week>>(value: [
        .monday, .thursday, .tuesday, .wednesday, .friday
    ])
    
    let planNameLabel: UILabel = {
        let view = UILabel()
        view.text = "목표"
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 17)
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
            borderColor: .systemIndigo
        )
        view.placeholder = "ex) 달리기 100주"
        return view
    }()
    
    let planTargetPeriodLabel: UILabel = {
        let view = UILabel()
        view.text = "목표 기간 설정 (옵션)"
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 17)
        return view
    }()
    
    let numberOfDaysToAchieveLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.rounded()
        view.backgroundColor = .systemIndigo
        view.innerView.text = "3일"
        view.innerView.textAlignment = .center
        view.innerView.textColor = .white
        return view
    }()
    
    lazy var targetNumberOfDaysSettingButton = ResizableButton(
        image: UIImage(resource: .calendar),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label,
        target: self,
        action: #selector(targetNumberOfDaysSettingButtonDidTapped)
    )
    
    let planRequiredDoingDayLabel: UILabel = {
        let view = UILabel()
        view.text = "목표 실행일 설정"
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 17)
        return view
    }()
    
    lazy var planRequiredDoingDayStackView: UIStackView = {
        let dayButtons = Week.allCases.map { day in
            let button = ResizableButton(
                title: day.kor, font: .boldSystemFont(ofSize: 17),
                tintColor: .black, backgroundColor: .systemBackground,
                target: self,
                action: #selector(planRequiredDoingDayButtonDidTapped)
            )
            button.titleLabel?.textAlignment = .center
            button.bordered(borderWidth: 0.5, borderColor: .systemIndigo)
            
            button.tag = day.rawValue
            return button
        }
        
        let view = UIStackView(arrangedSubviews: dayButtons)
        view.spacing = 3
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        return view
    }()
    
    let descriptionLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.text = " - 목표 시작일은 목표 생성일 이후 날짜로 설정할 수 있습니다.\n\n - 목표 기간 설정을 하지않으면 기본 3일로 설정됩니다.\n\n - 목표 실행일은 기본적으로 주5일 (월~금)으로 설정됩니다."
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
        
        initialConfiguration()
    }
    
    func initialConfiguration() {
        let buttons = planRequiredDoingDayStackView
            .arrangedSubviews
            .compactMap { $0 as? UIButton }
        /// 월~금까지 기본 선택
        buttons
            .filter { $0.tag < 5 }
            .forEach { self.select($0) }
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
    
    private func configureViews() {
        backgroundColor = .systemBackground
        
        addSubview(planNameLabel)
        addSubview(planNameTextField)
        addSubview(planNameMaximumTextNumberLabel)
        addSubview(planTargetPeriodLabel)
        addSubview(numberOfDaysToAchieveLabel)
        addSubview(targetNumberOfDaysSettingButton)
        addSubview(planRequiredDoingDayLabel)
        addSubview(planRequiredDoingDayStackView)
        addSubview(descriptionLabel)
        addSubview(createButton)
    }
    
    private func setConstraints() {
        
        self.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(self.frameLayoutGuide.snp.width)
        }
        
        planNameLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(self.contentLayoutGuide).inset(20)
        }
        planNameMaximumTextNumberLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentLayoutGuide).inset(20)
            make.bottom.equalTo(planNameTextField.snp.top).offset(-10)
        }
        planNameTextField.snp.makeConstraints { make in
            make.top.equalTo(planNameLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
        }
        planTargetPeriodLabel.snp.makeConstraints { make in
            make.top.equalTo(planNameTextField.snp.bottom).offset(30)
            make.leading.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        numberOfDaysToAchieveLabel.snp.makeConstraints { make in
            make.top.equalTo(planTargetPeriodLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        targetNumberOfDaysSettingButton.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(numberOfDaysToAchieveLabel.snp.trailing).offset(-10)
            make.centerY.equalTo(numberOfDaysToAchieveLabel)
            make.trailing.equalTo(contentLayoutGuide).inset(30)
        }
        
        planRequiredDoingDayLabel.snp.makeConstraints { make in
            make.top.equalTo(numberOfDaysToAchieveLabel.snp.bottom).offset(50)
            make.leading.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        planRequiredDoingDayStackView.snp.makeConstraints { make in
            make.top.equalTo(planRequiredDoingDayLabel.snp.bottom).offset(30)
            
            let inset = 20.0
            let deviceWidth = UIScreen.main.bounds.width
            
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(inset)
            make.height.equalTo((deviceWidth - (inset * 2) - (3 * 6)) / 7)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(planRequiredDoingDayStackView.snp.bottom).offset(50)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
            make.bottom.equalTo(contentLayoutGuide).offset(-10)
        }
    }
}

extension CreatePlanView {
    @objc func targetNumberOfDaysSettingButtonDidTapped() {
        buttonDelegate?.calendarButtonDidTapped()
    }
    
    @objc func planRequiredDoingDayButtonDidTapped(_ button: UIButton) {
        select(button)
        updateSelectedDays(data: button.tag)
    }
    
    private func select(_ button: UIButton) {
        button.isSelected.toggle()
        button.backgroundColor = button.isSelected ? .systemIndigo : .systemBackground
        button.setTitleColor(button.isSelected ? .white : .black, for: .normal)
    }
    
    private func updateSelectedDays(data: Int) {
        guard let week = Week(rawValue: data) else { return }
        do {
            var _selectedDays = try selectedDays.value()
            if _selectedDays.contains(week) {
                _selectedDays.remove(week)
            } else {
                _selectedDays.insert(week)
            }
            selectedDays.onNext(_selectedDays)
        } catch {
            print(error)
        }
    }
}
