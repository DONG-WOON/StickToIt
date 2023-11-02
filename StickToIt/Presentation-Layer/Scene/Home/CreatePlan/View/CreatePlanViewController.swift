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
    private let input = PublishSubject<CreatePlanViewModel.Input>()
    private let disposeBag = DisposeBag()
    
    // MARK: UI Properties
    private let mainView = CreatePlanView()
    
    private lazy var dismissButton = ResizableButton(
        image: UIImage(resource: .xmark),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, backgroundColor: .clear, target: self,
        action: #selector(dismissButtonDidTapped)
    )
    
    private lazy var createButton = ResizableButton(
        title: StringKey.createPlan.localized(),
        font: .boldSystemFont(ofSize: 20),
        tintColor: .white,
        backgroundColor: .assetColor(.accent1),
        target: self,
        action: #selector(createButtonDidTapped)
    )
    
    
    // MARK: Life Cycle
    init(viewModel: CreatePlanViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input.onNext(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainView.planNameTextField.innerView.becomeFirstResponder()
    }
    
    private func bind() {
        viewModel
            .transform(input: input.asObserver())
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { owner, output in
                switch output {
                case .configureUI:
                    owner.configureViews()
                    owner.setConstraints()
                    
                case .updateEndDateTitle(let dateString):
                    owner.updateEndDateTitle(dateString)
                    
                case .planIsValidated(let isValidated):
                    owner.updateCreateButton(isValidated: isValidated)
                    
                case .createPlanCompleted:
                    owner.goBackHome()
                    
                case .showAlert(let message):
                    owner.showAlert(
                        title: StringKey.noti.localized(),
                        message: message
                    )
                    
                case .presentCalendar(withStartDate: let startDate, endDate: let endDate):
                    owner.presentCalendarVC(with: startDate, endDate: endDate)
                }
            }
            .disposed(by: disposeBag)
        
        mainView.planNameTextField
            .innerView.rx.text
            .orEmpty
            .map { String($0.prefix(20)) }
            .bind(with: self) { owner, text in
                owner.mainView.planNameTextField.innerView.text = text
                owner.mainView.planNameMaximumTextNumberLabel.text = "\(text.count) / 20"
                owner.updateTextFieldBorder(text: text)
                owner.input.onNext(.planNameTextInput(text))
            }
            .disposed(by: disposeBag)
        
        mainView.planStartDateSegment.rx.selectedSegmentIndex
            .bind(with: input, onNext: { owner, index in
                owner.onNext(.startDateSelected(index))
            })
            .disposed(by: disposeBag)
    }
}

extension CreatePlanViewController {
    
    private func updateTextFieldBorder(text: String) {
        mainView.planNameTextField.bordered(
            borderWidth: !text.isEmpty ? 1 : 0.5,
            borderColor: .assetColor(.accent1)
        )
    }
    
    private func updateCreateButton(isValidated: Bool) {
        createButton.isEnabled = isValidated
        createButton.backgroundColor = isValidated ? .assetColor(.accent1) : .gray
    }
    
    private func updateEndDateTitle(_ text: String) {
        mainView.endDateLabel.innerView.text = StringKey.endDateTitleSetting.localized(with: text)
    }
    
    private func goBackHome() {
        NotificationCenter.default.post(name: .planCreated, object: nil)
        self.dismiss(animated: true)
    }
    
    @MainActor
    private func presentCalendarVC(with startDate: Date, endDate: Date) {
        let popupVC = CreatePlanTargetPeriodSettingViewController(
            startDate: startDate,
            endDate: endDate
        )
        
        popupVC.delegate = self
        popupVC.modalTransitionStyle = .crossDissolve
        popupVC.modalPresentationStyle = .overFullScreen
        
        present(popupVC, animated: true)
    }
}

extension CreatePlanViewController: BaseViewConfigurable {
    
    func configureViews() {
        self.title = StringKey.createPlan.localized()
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        
        mainView.buttonDelegate = self
        createButton.rounded()
        
        view.addSubview(mainView)
        view.addSubview(createButton)
    }
    
    func setConstraints() {
        
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
            title: StringKey.warning.localized(),
            message: StringKey.dismissMessage.localized(),
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: StringKey.yes.localized(),
            style: .destructive) { _ in
            self.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: StringKey.no.localized(), style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    @objc private func createButtonDidTapped() {
        input.onNext(.createPlanButtonDidTapped)
    }
}

extension CreatePlanViewController: CalendarButtonProtocol {
    
    func endDateSettingButtonDidTapped() {
        input.onNext(.calendarButtonDidTapped)
    }
}

extension CreatePlanViewController: PlanTargetNumberOfDaysSettingDelegate {
    
    func okButtonDidTapped(date: Date) {
        input.onNext(.endDateIsSelected(date: date))
    }
}
