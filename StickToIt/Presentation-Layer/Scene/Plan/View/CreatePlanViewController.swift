//
//  CreatePlanViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/3/23.
//

import UIKit
import RxSwift
import RxCocoa

final class CreatePlanViewController: UIViewController {
    
    let viewModel = CreatePlanViewModel(
        useCase: CreatePlanUseCaseImpl(
            repository: PlanRepositoryImpl(
                networkService: nil,
                databaseManager: PlanDatabaseManager()
            )
        )
    )

    private let disposeBag = DisposeBag()
    
    // MARK: UI Properties
    
    let mainView = CreatePlanView()
    
    private lazy var dismissButton = ResizableButton(
        image: UIImage(resource: .xmark),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, backgroundColor: .clear, target: self,
        action: #selector(dismissButtonDidTapped)
    )
    
    private lazy var createButton: ResizableButton = {
        let button = ResizableButton(
            title: "목표 생성하기",
            font: .boldSystemFont(ofSize: 20),
            tintColor: .white,
            backgroundColor: .assetColor(.accent1),
            target: self,
            action: #selector(createButtonDidTapped)
        )
        button.rounded(cornerRadius: 20)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        configureViews()
        setConstraints()
        
    }
    
    private func bindViewModel() {
        
        viewModel.planIsValidated
            .bind(with: self) { (_self, isValidated) in
                _self.createButton.isEnabled = isValidated
                _self.createButton.backgroundColor = isValidated ? .assetColor(.accent1) : .gray
            }
            .disposed(by: disposeBag)
        
        
        mainView.planNameTextField
            .innerView.rx.text
            .orEmpty
            .asObservable()
            .map { String($0.prefix(20)) }
            .subscribe(with: self) { (_self, text) in
                _self.mainView.planNameTextField.innerView.text = text
                _self.mainView.planNameMaximumTextNumberLabel.text = "\(text.count) / 20"
                _self.viewModel.planName.accept(text)
            }
            .disposed(by: disposeBag)
        
        viewModel.endDate
            .bind(with: self) { (_self, date) in
                guard let _date = date else { return }
                let endDateString = DateFormatter.getFullDateString(from: _date)
                self.mainView.endDateLabel.innerView.text = "종료일: \(endDateString)"
                
                _self.setTargetNumberOfDays(date: _date)
                
            }
            .disposed(by: disposeBag)
    }
    
    func setTargetNumberOfDays(date: Date?) {
        guard let date else { return }
        
        guard let dayInterval = Calendar.current.dateComponents([.day], from: viewModel.startDate, to: date).day else { return }
        
        let diffOfStartDateAndEndDate = dayInterval + 1
        self.viewModel.targetNumberOfDays = diffOfStartDateAndEndDate
        
        let datesFromStartDateToEndDate = Array(0...diffOfStartDateAndEndDate).map { Calendar.current.date(byAdding: .day, value: $0, to: viewModel.startDate)!
        }
        
        let weekdayList = datesFromStartDateToEndDate.map {
            return Calendar.current.dateComponents([.weekday], from: $0).weekday!
        }
        
        if weekdayList.count < 7 {
        
            mainView.executionDaysOfWeekdayCollectionView
                .disable(indexAtCell: weekdayList)
        } else {
            mainView.executionDaysOfWeekdayCollectionView
                .enableAllCell()
        }
    }
    
    private func configureViews() {
        self.title = "계획 생성"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        
        mainView.buttonDelegate = self
        mainView.dayCellDelegate = self
        
        view.addSubview(mainView)
        view.addSubview(createButton)
    }
    
    private func setConstraints() {
        
        mainView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(createButton.snp.top).offset(-10)
        }
        
        createButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-10)
        }
    }
    
    
    @objc private func dismissButtonDidTapped() {
        let alert = UIAlertController(
            title: "주의",
            message: "지금 닫으면 생성하던 계획 내용이 사라집니다. 그래도 나가시겠습니까?",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: "예",
            style: .destructive) { _ in
            self.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "아니오", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    @objc private func createButtonDidTapped() {
        viewModel.createPlan { [weak self] result in
            switch result {
            case .success(let planQuery):
                NotificationCenter.default.post(name: .reloadAll, object: planQuery)
                self?.dismiss(animated: true)
            case .failure:
                print("생성에 실패, 잠시 후 다시 시도해주세요!")
            }
        }
    }
}

extension CreatePlanViewController: CalendarButtonProtocol {
    
    func endDateSettingButtonDidTapped() {
        let endDate = viewModel.endDate.value
        let twoDaysLater = Calendar.current.date(byAdding: .day, value: 2, to: Date.now)!
        let defaultDate = DateFormatter.convertDate(from: twoDaysLater)!
        let popupVC = CreatePlanTargetPeriodSettingViewController(date: endDate ?? defaultDate)
        popupVC.delegate = self
        
        popupVC.modalTransitionStyle = .crossDissolve
        popupVC.modalPresentationStyle = .overFullScreen
        
        present(popupVC, animated: true)
    }
}

extension CreatePlanViewController: PlanTargetNumberOfDaysSettingDelegate {
    
    func okButtonDidTapped(date: Date?) {
        self.viewModel.endDate.accept(date)
        self.viewModel.executionDaysOfWeekday.accept([])
    }
}

extension CreatePlanViewController: DayCellDelegate {
    
    func select(week: Week?) {
        guard let week else { return }
        var weeks = viewModel.executionDaysOfWeekday.value
        weeks.insert(week)
        viewModel.executionDaysOfWeekday
            .accept(weeks)
    }
    
    func deSelect(week: Week?) {
        guard let week else { return }
        var weeks = viewModel.executionDaysOfWeekday.value
        weeks.remove(week)
        viewModel.executionDaysOfWeekday
            .accept(
                weeks
            )
    }
}
