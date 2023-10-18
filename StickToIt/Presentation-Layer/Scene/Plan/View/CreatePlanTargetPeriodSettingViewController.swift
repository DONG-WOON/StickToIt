//
//  CreatePlanTargetPeriodSettingViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/4/23.
//

import UIKit

protocol PlanTargetNumberOfDaysSettingDelegate: AnyObject {
     
     func okButtonDidTapped(date: Date?)
}

final class CreatePlanTargetPeriodSettingViewController: UIViewController {
     
     weak var delegate: PlanTargetNumberOfDaysSettingDelegate?
     
     private var date: Date? {
          willSet {
               guard let  _newValue = newValue else { return }
               guard let days = Calendar.current.dateComponents([.day], from: .now, to: _newValue).day else { return }
               
               self.dDayLabel.innerView.text = "오늘부터 \(days + 2) 동안"
          }
     }
     
     let containerView: UIView = {
          let view = UIView(backgroundColor: .assetColor(.accent4))
          view.rounded(cornerRadius:20)
          return view
     }()
     
     let calendar = StickToItCalendar(backgroundColor: .assetColor(.accent4))
     
     private let dDayLabel: PaddingView<UILabel> = {
          let view = PaddingView<UILabel>()
          view.innerView.text = "오늘부터 3일 동안"
          view.innerView.textAlignment = .center
          view.innerView.textColor = .assetColor(.accent2)
          return view
     }()
     
     private lazy var okButton: ResizableButton = {
          let button = ResizableButton(
               title: "확인",
               font: .boldSystemFont(ofSize: 18),
               tintColor: .white,
               backgroundColor: .assetColor(.accent1),
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
     
     init(date: Date) {
          self.date = date
          super.init(nibName: nil, bundle: nil)
     }
     
     required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
     }
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          configureViews()
          setConstraints()
          
          calendar.delegate = self
          
          calendar.setMinimumDate(
               Calendar
                    .current
                    .date(
                         byAdding: .day,
                         value: 2,
                         to: .now
                    )
          )
          
          calendar.select(date: date)
     }
     
     @objc private func dismissButtonDidTapped() {
          self.dismiss(animated: true)
     }
     
     @objc private func okButtonDidTapped() {
          delegate?.okButtonDidTapped(date: date)
          self.dismiss(animated: true)
     }
}

extension CreatePlanTargetPeriodSettingViewController: StickToItCalendarDelegate {
     
     func calendarView(didSelectAt date: Date?) {
          
          self.date = date
          
          UIView.animate(withDuration: 0.4) {
               self.dDayLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
          } completion: { _ in
               self.dDayLabel.transform = .identity
          }
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
