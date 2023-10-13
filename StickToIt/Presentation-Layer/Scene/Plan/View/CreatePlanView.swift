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
    func startDateSettingButtonDidTapped()
    func endDateSettingButtonDidTapped()
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
        view.text = "목표 기간 설정 (최소 3일!)"
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 17)
        return view
    }()
    
    let startDateLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.bordered(cornerRadius: 10, borderWidth: 0.7, borderColor: .systemIndigo)
        view.innerView.text = "시작일: \(DateFormatter.getFullDateString(from: Date.now))"
        view.innerView.backgroundColor = .clear
        view.innerView.textColor = .label
        return view
    }()

    let endDateLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.bordered(cornerRadius: 10, borderWidth: 0.7, borderColor: .systemIndigo)
        let date = Calendar.current.date(byAdding: .day, value: 2, to: .now)
        view.innerView.text = "종료일: \(DateFormatter.getFullDateString(from: date!))"
        view.innerView.backgroundColor = .clear
        view.innerView.textColor = .label
        return view
    }()
    
    
    lazy var startDateSettingButton: ResizableButton = {
        let button = ResizableButton(
            image: UIImage(resource: .calendar),
            symbolConfiguration: .init(scale: .large),
            tintColor: .white,
            backgroundColor: .systemIndigo,
            target: self,
            action: #selector(startDateSettingButtonDidTapped)
        )
        return button
    }()
    
    lazy var endDateSettingButton: ResizableButton = {
        let button = ResizableButton(
            image: UIImage(resource: .calendar),
            symbolConfiguration: .init(scale: .large),
            tintColor: .white,
            backgroundColor: .systemIndigo,
            target: self,
            action: #selector(endDateSettingButtonDidTapped)
        )
        return button
    }()
    
    let planRequiredDoingDayLabel: UILabel = {
        let view = UILabel()
        view.text = "목표 실행일 설정"
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 17)
        return view
    }()
    
    lazy var executionDaysOfWeekdayStackView: UIStackView = {
        let weekDay: [Week] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        let dayButtons = weekDay.map { day in
            let button = ResizableButton(
                title: day.kor, font: .boldSystemFont(ofSize: 17),
                tintColor: .label, backgroundColor: .systemBackground,
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
        let buttons = executionDaysOfWeekdayStackView
            .arrangedSubviews
            .compactMap { $0 as? UIButton }
        /// 월~금까지 기본 선택
        buttons
            .filter { $0.tag < 7 && $0.tag > 1 }
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
    
    @objc func startDateSettingButtonDidTapped() {
        buttonDelegate?.startDateSettingButtonDidTapped()
    }
    
    @objc func endDateSettingButtonDidTapped() {
        buttonDelegate?.endDateSettingButtonDidTapped()
    }
    
    @objc func planRequiredDoingDayButtonDidTapped(_ button: UIButton) {
        select(button)
        updateSelectedDays(data: button.tag)
    }
    
    private func select(_ button: UIButton) {
        button.isSelected.toggle()
        button.backgroundColor = button.isSelected ? .systemIndigo : .systemBackground
        button.setTitleColor(button.isSelected ? .white : .label, for: .normal)
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
    
    func update(plan: Plan) {
        planNameLabel.text = plan.name
        plan.executionDaysOfWeekday.forEach { week in
            (executionDaysOfWeekdayStackView.arrangedSubviews[week.rawValue - 1] as? UIButton)?.isSelected = true
        }
        startDateLabel.innerView.text = "시작일: \(DateFormatter.getFullDateString(from: plan.startDate))"
        
        startDateLabel.innerView.text = "종료일: \(DateFormatter.getFullDateString(from: plan.endDate))"
    }
}

extension CreatePlanView {
    
    private func configureViews() {
        backgroundColor = .systemBackground
        
        addSubview(planNameLabel)
        addSubview(planNameTextField)
        addSubview(planNameMaximumTextNumberLabel)
        addSubview(planTargetPeriodLabel)
        addSubview(startDateLabel)
        addSubview(endDateLabel)
        addSubview(planRequiredDoingDayLabel)
        addSubview(executionDaysOfWeekdayStackView)
        addSubview(descriptionLabel)
        addSubview(createButton)
        
        startDateLabel.addSubview(startDateSettingButton)
        endDateLabel.addSubview(endDateSettingButton)
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
            make.top.equalTo(planNameLabel.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        planTargetPeriodLabel.snp.makeConstraints { make in
            make.top.equalTo(planNameTextField.snp.bottom).offset(30)
            make.leading.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        startDateLabel.snp.makeConstraints { make in
            make.top.equalTo(planTargetPeriodLabel.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
        
        endDateLabel.snp.makeConstraints { make in
            make.top.equalTo(startDateLabel.snp.bottom).offset(40)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
        
        startDateSettingButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(startDateSettingButton.snp.height)
        }
        
        endDateSettingButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(endDateSettingButton.snp.height)
        }
        
        planRequiredDoingDayLabel.snp.makeConstraints { make in
            make.top.equalTo(endDateLabel.snp.bottom).offset(50)
            make.leading.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        executionDaysOfWeekdayStackView.snp.makeConstraints { make in
            make.top.equalTo(planRequiredDoingDayLabel.snp.bottom).offset(30)
            
            let inset = 20.0
            let deviceWidth = UIScreen.main.bounds.width
            
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(inset)
            make.height.equalTo((deviceWidth - (inset * 2) - (3 * 6)) / 7)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(executionDaysOfWeekdayStackView.snp.bottom).offset(50)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
            make.bottom.equalTo(contentLayoutGuide).offset(-10)
        }
    }
}
