//
//  UserSettingViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/17/23.
//

import UIKit
import RxSwift
import RxCocoa

class UserSettingViewController: UIViewController {
    
    private let viewModel: UserSettingViewModel
    
    private let input = PublishSubject<UserSettingViewModel.Input>()
    private let disposeBag = DisposeBag()
    
    // MARK: UI Properties
    
    private let nicknameLabel: UILabel = {
        let view = UILabel()
        view.text = StringKey.nickname.localized()
        view.textColor = .label
        view.font = .systemFont(ofSize: 20, weight: .semibold)
        return view
    }()
    
    private let validateLabel: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.font = .systemFont(ofSize: 17)
        return view
    }()
    
    private lazy var nicknameTextField: PaddingView<UITextField> = {
        let view = PaddingView<UITextField>()
        view.innerView.placeholder = StringKey.nicknamePlaceholder.localized()
        view.innerView.textColor = .label
        view.innerView.borderStyle = .none
        view.innerView.clearButtonMode = .whileEditing
        view.innerView.font = .systemFont(ofSize: 17)
        view.bordered(borderWidth: 1, borderColor: .assetColor(.accent2))
        return view
    }()
    
    private var descriptionLabel: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.text = StringKey.userSettingDescriptionLabel.localized()
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    private lazy var registerButton: ResizableButton = {
        let button = ResizableButton(
            title: StringKey.register.localized(),
            font: .boldSystemFont(ofSize: 20),
            tintColor: .white,
            backgroundColor: .assetColor(.accent1),
            target: self,
            action: #selector(registerButtonDidTapped)
        )
        button.rounded()
        return button
    }()
    
    
    init(viewModel: UserSettingViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        bind()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("🔥 ", self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        setConstraints()
    }
    
    func bind() {
        viewModel
            .transform(input: input.asObserver())
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { (_self, event) in
                switch event {
                case .completeUserRegistration:
                    
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    let sceneDelegate = windowScene?.delegate as? SceneDelegate
                    let window = sceneDelegate?.window
                    let mainVC = TabBarController()
                    
                    window?.rootViewController = mainVC
                    window?.makeKeyAndVisible()
                    
                    if let window {
                        UIView.transition(with: window,
                                          duration: 0.6,
                                          options: .transitionCrossDissolve,
                                          animations: nil)
                    }
                    
                case .userNicknameValidate(let isValidated):
                    _self.registerButton.isEnabled = isValidated
                    _self.registerButton.backgroundColor = isValidated ? .assetColor(.accent1) : .gray
                    
                case .validateError(let errorMessage):
                    guard let errorMessage else {
                        _self.validateLabel.text = StringKey.validateNicknameLabel.localized()
                        _self.validateLabel.textColor = .assetColor(.accent1)
                        return
                    }
                    _self.validateLabel.text = errorMessage
                    _self.validateLabel.textColor = .systemRed
                }
            }
            .disposed(by: disposeBag)
       
        nicknameTextField.innerView.rx.text
            .orEmpty
            .asObservable()
            .map{ String($0.prefix(20)) }
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { (_self, text) in
                _self.nicknameTextField.innerView.text = text
                _self.input.onNext(.textInput(text: text))
            }
            .disposed(by: disposeBag)
    }
}

extension UserSettingViewController {
    @objc func registerButtonDidTapped() {
        input.onNext(.registerButtonDidTapped)
    }
}

extension UserSettingViewController: BaseViewConfigurable {
    func configureViews() {
        view.backgroundColor = .systemBackground
        
        title = StringKey.register.localized()
        
        view.addSubview(nicknameLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(validateLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(registerButton)
    }
    
    func setConstraints() {
        nicknameLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(33)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(18)
            make.height.equalTo(45)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        
        validateLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(33)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(validateLabel.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(33)
        }
        
        registerButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-10)
            make.height.equalTo(60)
        }
    }
}
