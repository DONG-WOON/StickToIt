//
//  CreatePlanTargetPeriodSettingViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/4/23.
//

import UIKit

protocol PlanTargetPeriodSettingDelegate: AnyObject {
    func planTargetPeriodSetting(_ data: (date: Date?, day: Int?))
}

final class CreatePlanTargetPeriodSettingViewController: UIViewController {
    
    weak var delegate: PlanTargetPeriodSettingDelegate?
    
    var selectedDateAndDay: (date: Date?, day: Int?)
    
    let containerView: UIView = {
        let view = UIView(backgroundColor: .systemBackground)
        view.rounded(cornerRadius:20)
        return view
    }()
    
    let calendar = StickToItCalendar(backgroundColor: .systemBackground)
    
    private let dDayLabel: BorderedView<UILabel> = {
        let view = BorderedView<UILabel>()
        view.rounded()
        view.backgroundColor = .systemIndigo
        view.innerView.text = "3일"
        view.innerView.textAlignment = .center
        view.innerView.textColor = .white
        return view
    }()
    
    private lazy var okButton: ResizableButton = {
        let button = ResizableButton(
            title: "확인",
            font: .boldSystemFont(ofSize: 18),
            tintColor: .white,
            backgroundColor: .systemIndigo,
            target: self,
            action: #selector(okButtonDidTapped)
        )
        button.rounded(cornerRadius: 20)
        return button
    }()
    
    private lazy var dismissButton = ResizableButton(
        image: UIImage(resource: .xmark),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, target: self,
        action: #selector(dismissButtonDidTapped)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        setConstraints()
        
        calendar.delegate = self
        calendar.setMinimumDate(Calendar(identifier: .gregorian) .date(byAdding: .day, value: 1, to: Date.now))
        calendar.select(date: Calendar(identifier: .gregorian).date(byAdding: .day, value: 3, to: Date.now))
    }
    
    @objc private func dismissButtonDidTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func okButtonDidTapped() {
        delegate?.planTargetPeriodSetting(selectedDateAndDay)
        self.dismiss(animated: true)
    }
}

extension CreatePlanTargetPeriodSettingViewController: StickToItCalendarDelegate {
    func calendarView(didSelectAt date: Date) {
        guard let day = Calendar(identifier: .gregorian).dateComponents([.day], from: Date.now, to: date).day else { return }
        self.selectedDateAndDay = (date, day)
        self.dDayLabel.innerView.text = "\(day)일"
    }
}

extension CreatePlanTargetPeriodSettingViewController {
    
    fileprivate func configureViews() {
        view.backgroundColor = .gray.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        
        containerView.addSubview(dismissButton)
        containerView.addSubview(dDayLabel)
        containerView.addSubview(calendar)
        containerView.addSubview(okButton)
    }
    
    fileprivate func setConstraints() {
        containerView.snp.makeConstraints { make in
            make.height.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.7)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerY.equalTo(view.safeAreaLayoutGuide)
        }
        
        dDayLabel.snp.makeConstraints { make in
            make.top.trailing.equalTo(containerView).inset(20)
        }
        
        dismissButton.snp.makeConstraints { make in
            make.top.leading.equalTo(containerView).inset(15)
            make.height.equalTo(20)
        }
        
        calendar.snp.makeConstraints { make in
            make.top.equalTo(dDayLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(containerView).inset(5)
        }
        
        okButton.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(containerView).inset(5)
            make.height.equalTo(50)
            make.bottom.equalTo(containerView).inset(5)
        }
    }
}
