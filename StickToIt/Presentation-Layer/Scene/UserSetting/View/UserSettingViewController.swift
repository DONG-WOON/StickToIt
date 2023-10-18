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
        view.text = "닉네임"
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
        view.innerView.placeholder = "닉네임 1자 이상 20자 이하"
        view.innerView.textColor = .label
        view.innerView.borderStyle = .none
        view.innerView.clearButtonMode = .whileEditing
        view.innerView.font = .systemFont(ofSize: 17)
        return view
    }()
    
    private var descriptionLabel: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.text = "- 닉네임은 언제든 다시 수정할 수 있어요"
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    private lazy var registerButton: ResizableButton = {
        let button = ResizableButton(
            title: "사용자 등록하기",
            font: .boldSystemFont(ofSize: 20),
            tintColor: .white,
            target: self,
            action: #selector(registerButtonDidTapped)
        )
        button.rounded(cornerRadius: 20)
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
                    
                case .userNameValidate(let isValidated):
                    _self.registerButton.isEnabled = isValidated
                    
                case .validateError(let errorMessage):
                    guard let errorMessage else {
                        _self.validateLabel.text = "유효한 닉네임 입니다."
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
            .map{ String($0.prefix(30)) }
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { (_self, text) in
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
        
        title = "사용자 등록"
        
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
