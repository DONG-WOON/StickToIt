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
    
    private let viewModel: CreatePlanViewModel

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
        button.rounded()
        return button
    }()
    
    init(viewModel: CreatePlanViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        configureViews()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainView.planNameTextField.innerView.becomeFirstResponder()
    }
    
    deinit {
        print("🔥 ", self)
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
                _self.viewModel.planName.onNext(text)
                
                if !text.isEmpty {
                    _self.mainView.planNameTextField.bordered(borderWidth: 1, borderColor: .assetColor(.accent1))
                } else {
                    _self.mainView.planNameTextField.bordered(borderWidth: 0.5, borderColor: .assetColor(.accent1))
                }
            }
            .disposed(by: disposeBag)
        
        mainView.planStartDateSegment.rx.selectedSegmentIndex
            .asObservable()
            .subscribe(with: self) { _self, index in
                switch index {
                case 0:
                    _self.viewModel.startDate = .now
                    _self.viewModel.endDate.accept(nil)
                    _self.mainView.planNameTextField.innerView.resignFirstResponder()
                case 1:
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
                    _self.viewModel.startDate = tomorrow
                    _self.viewModel.endDate.accept(nil)
                    _self.mainView.planNameTextField.innerView.resignFirstResponder()
                default:
                    return
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.endDate
            .bind(with: self) { (_self, date) in
                guard let _date = date else {
                    _self.mainView.endDateLabel.innerView.text = "종료일을 설정해주세요 ---->"
                    return
                }
                let endDateString = DateFormatter.getFullDateString(from: _date)
                _self.mainView.endDateLabel.innerView.text = "종료일: \(endDateString)"
                
                _self.setTargetNumberOfDays(date: _date)
            }
            .disposed(by: disposeBag)
    }
    
    func setTargetNumberOfDays(date: Date) {
        guard let dayInterval = Calendar.current.dateComponents([.day], from: viewModel.startDate, to: date).day else { return }
        
        let diffOfStartDateAndEndDate = dayInterval + 1
        
        self.viewModel.targetNumberOfDays = diffOfStartDateAndEndDate
        
        let datesFromStartDateToEndDate = Array(0...diffOfStartDateAndEndDate).map { Calendar.current.date(byAdding: .day, value: $0, to: viewModel.startDate)!
        }
        
        let weekdayList = datesFromStartDateToEndDate.map {
            return Calendar.current.dateComponents([.weekday], from: $0).weekday!
        }
    }
    
    private func configureViews() {
        self.title = "작심삼일 목표 생성"
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
            message: "지금 닫으면 작성한 내용은 사라집니다. 그래도 나가시겠습니까?",
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
                NotificationCenter.default.post(name: .planCreated, object: planQuery)
                self?.dismiss(animated: true)
            case .failure:
                print("목표 생성 실패, 잠시 후 다시 시도해주세요!")
            }
        }
    }
}

extension CreatePlanViewController: CalendarButtonProtocol {
    
    func endDateSettingButtonDidTapped() {
        let endDate = viewModel.endDate.value
        let twoDaysLater = Calendar.current.date(byAdding: .day, value: 2, to: viewModel.startDate)!
        let defaultDate = DateFormatter.convertDate(from: twoDaysLater)!
        let popupVC = CreatePlanTargetPeriodSettingViewController(startDate: viewModel.startDate, endDate: endDate ?? defaultDate)
        popupVC.delegate = self
        
        popupVC.modalTransitionStyle = .crossDissolve
        popupVC.modalPresentationStyle = .overFullScreen
        
        present(popupVC, animated: true)
    }
}

extension CreatePlanViewController: PlanTargetNumberOfDaysSettingDelegate {
    
    func okButtonDidTapped(date: Date?) {
        self.viewModel.endDate.accept(date)
    }
}
