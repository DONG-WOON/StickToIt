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
        createPlanUseCase: CreatePlanUseCase(
            planRepository: DefaultPlanRepository(
                networkService: nil,
                databaseManager: PlanDatabaseManager(queue: .main)
            )
        )
    )
    
    private var disposeBag = DisposeBag()
    
    // MARK: UI Properties
    
    let mainView = CreatePlanView()
    
    private lazy var dismissButton = ResizableButton(
        image: UIImage(resource: .xmark),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, target: self,
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
    }
    
    private func bindViewModel() {
        
        viewModel.planIsValidated
            .bind(with: self) { (_self, isValidated) in
                _self.createButton.isEnabled = isValidated
                _self.createButton.backgroundColor = isValidated ? .systemIndigo : .gray
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
                    .executionDaysOfWeek
                    .onNext(_week)
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
        viewModel.createPlan()
        #warning("성공메세지 보여주기")
        self.dismiss(animated: true)
    }
}

extension CreatePlanViewController: CalendarButtonProtocol {
    func calendarButtonDidTapped() {
        let popupVC = CreatePlanTargetPeriodSettingViewController()
        popupVC.delegate = self
        popupVC.modalTransitionStyle = .crossDissolve
        popupVC.modalPresentationStyle = .overFullScreen
        
        present(popupVC, animated: true)
    }
}

extension CreatePlanViewController: PlanTargetPeriodSettingDelegate {
    func planTargetPeriodSetting(_ data: (date: Date?, day: Int?)) {
        if let date = data.date {
            print(date)
        }
        if let day = data.day {
            self.viewModel.targetPeriod.accept(day)
            self.mainView.numberOfDaysToAchieveLabel.innerView.text = "\(day)일"
        }
    }
}
