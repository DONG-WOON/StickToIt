//
//  CreatePlanViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/3/23.
//

import UIKit
import RxSwift
import RxCocoa

protocol CreatePlanCompletedDelegate: AnyObject {
    func createPlanCompleted()
}

final class CreatePlanViewController: UIViewController {
    
    let viewModel = CreatePlanViewModel(
        useCase: CreatePlanUseCaseImpl(
            repository: PlanRepositoryImpl(
                networkService: nil,
                databaseManager: PlanDatabaseManager()
            )
        )
    )
    
    weak var delegate: CreatePlanCompletedDelegate?
    
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
            backgroundColor: .systemIndigo,
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
        
        // FSCalendar 때문에 하루 뺴줌
        let date = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        
        reload(date: date)
    }
    
    private func bindViewModel() {
        
        viewModel.planIsValidated
            .bind(with: self) { (_self, isValidated) in
                _self.createButton.isEnabled = isValidated
                _self.createButton.backgroundColor = isValidated ? .systemIndigo.withAlphaComponent(0.6) : .gray
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
        
        mainView.selectedDays
            .bind(with: self) { (_self, _week) in
                _self.viewModel
                    .executionDaysOfWeekday
                    .accept(_week)
                print(_week)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureViews() {
        self.title = "목표 생성"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        
        mainView.buttonDelegate = self
        
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
            case .success:
                self?.delegate?.createPlanCompleted()
                self?.dismiss(animated: true)
            case .failure:
                print("생성에 실패, 잠시 후 다시 시도해주세요!")
            }
        }
    }
}

extension CreatePlanViewController: CalendarButtonProtocol {
    
    func endDateSettingButtonDidTapped() {
        let popupVC = CreatePlanTargetPeriodSettingViewController(date: viewModel.endDate)
        popupVC.delegate = self
        
        popupVC.modalTransitionStyle = .crossDissolve
        popupVC.modalPresentationStyle = .overFullScreen
        
        present(popupVC, animated: true)
    }
}

extension CreatePlanViewController: PlanTargetNumberOfDaysSettingDelegate {
    
    func okButtonDidTapped(date: Date) {
        self.viewModel.endDate = date
        
        let endDate = DateFormatter.getFullDateString(from: date)
        self.mainView.endDateLabel.innerView.text = "종료일: \(endDate)"
        
        reload(date: date)
    }
    
    func reload(date: Date) {
        guard let day = Calendar.current.dateComponents([.day], from: viewModel.startDate, to: date).day else { return }
        let diffOfStartDateAndEndDate = day + 2
        self.viewModel.targetNumberOfDays = diffOfStartDateAndEndDate
        
        let datesFromStartDateToEndDate = Array(0...day + 1).map { Calendar.current.date(byAdding: .day, value: $0, to: viewModel.startDate)!
        }
        
        let weekdayList = datesFromStartDateToEndDate.map {
            return Calendar.current.dateComponents([.weekday], from: $0).weekday!
        }
        
        
        if weekdayList.count < 7 {
            mainView.disableStackView(weekdayList: weekdayList)
        } else {
            mainView.executionDaysOfWeekdayStackView
                .arrangedSubviews
                .map { $0 as? UIButton }
                .forEach {
                    $0?.isEnabled = true
                    $0?.backgroundColor = .systemBackground
                }
        }
    }
}
