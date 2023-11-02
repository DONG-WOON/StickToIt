//
//  CreatePlanTargetPeriodSettingViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/4/23.
//

import UIKit
import RxSwift
import RxCocoa

protocol PlanTargetNumberOfDaysSettingDelegate: AnyObject {
     
     func okButtonDidTapped(date: Date)
}

final class CreatePlanTargetPeriodSettingViewController: UIViewController {
     
     weak var delegate: PlanTargetNumberOfDaysSettingDelegate?
     
     private var startDate = BehaviorRelay(value: Date.now)
     private let endDate = BehaviorRelay(value: Date.now.addDays(2))
     private let disposable = DisposeBag()
     
     let containerView: UIView = {
          let view = UIView(backgroundColor: .systemBackground)
          view.rounded(cornerRadius:20)
          return view
     }()
     
     let calendar = StickToItCalendar()
     
     private let dDayLabel: PaddingView<UILabel> = {
          let view = PaddingView<UILabel>()
          view.innerView.textAlignment = .center
          view.innerView.textColor = .assetColor(.accent2)
          return view
     }()
     
     private lazy var okButton: ResizableButton = {
          let button = ResizableButton(
               title: StringKey.done.localized(),
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
     
     init(startDate: Date, endDate: Date) {
          self.startDate.accept(startDate)
          self.endDate.accept(endDate)
          
          super.init(nibName: nil, bundle: nil)
          
          bind()
     }
     
     required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
     }
     
     func bind() {
          Observable.combineLatest(startDate, endDate)
               .map { (DateFormatter.convertDate(from: $0)!, DateFormatter.convertDate(from: $1)!) }
               .map { startDate, endDate in
                    let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day!
                    return StringKey.forDaysLabel.localized(with: "\(days + 1)")
               }
               .bind(to: dDayLabel.innerView.rx.text)
               .disposed(by: disposable)
     }
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          configureViews()
          setConstraints()
          
          calendar.delegate = self
          
          startDate
               .subscribe(with: self) { owner, date in
                    owner.calendar.setMinimumDate(date.addDays(2))
               }
               .dispose()
          
          endDate
               .subscribe(with: self) { owner, date in
                    owner.calendar.select(date: date)
               }
               .dispose()
     }
     
     @objc private func dismissButtonDidTapped() {
          self.dismiss(animated: true)
     }
     
     @objc private func okButtonDidTapped() {
          delegate?.okButtonDidTapped(date: endDate.value)
          self.dismiss(animated: true)
     }
}

extension CreatePlanTargetPeriodSettingViewController: StickToItCalendarDelegate {
     
     func calendarView(didSelectAt date: Date) {
          
          endDate.accept(date)
          
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
               make.centerY.equalTo(dismissButton)
               make.trailing.equalTo(containerView).inset(15)
          }
          
          dismissButton.snp.makeConstraints { make in
               make.top.leading.equalTo(containerView).inset(15)
               make.height.equalTo(20)
          }
          
          calendar.snp.makeConstraints { make in
               make.top.equalTo(dismissButton.snp.bottom).offset(10)
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
