//
//  UserEditingViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/30/23.
//
import UIKit
import RxSwift
import RxCocoa

class UserEditingViewController: UIViewController {
    
    private let viewModel: UserEditingViewModel
    
    private let input = PublishSubject<UserEditingViewModel.Input>()
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
    
    private lazy var editButton: ResizableButton = {
        let button = ResizableButton(
            title: StringKey.edit.localized(),
            font: .boldSystemFont(ofSize: 20),
            tintColor: .white,
            backgroundColor: .assetColor(.accent1),
            target: self,
            action: #selector(editButtonDidTapped)
        )
        button.rounded()
        return button
    }()
    
    
    init(viewModel: UserEditingViewModel) {
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
        input.onNext(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func bind() {
        viewModel
            .transform(input: input)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { (owner, event) in
                switch event {
                case .completeEditing:
                    owner.navigationController?.popViewController(animated: true)
                case .userNicknameValidate(let isValidated):
                    owner.editButton.isEnabled = isValidated
                    owner.editButton.backgroundColor = isValidated ? .assetColor(.accent1) : .gray
                    
                case .validateError(let errorMessage):
                    guard let errorMessage else {
                        owner.validateLabel.text = StringKey.validateNicknameLabel.localized()
                        owner.validateLabel.textColor = .assetColor(.accent1)
                        return
                    }
                    owner.validateLabel.text = errorMessage
                    owner.validateLabel.textColor = .systemRed
                case .showError(_):
                    owner.showAlert(title: StringKey.noti.localized(), message: "닉네임을 변경할 수 없습니다. 다음에 다시 시도해주세요!") {}
                case .updateNickname(let nickname):
                    owner.nicknameTextField.innerView.text = nickname
                }
            }
            .disposed(by: disposeBag)
       
        nicknameTextField.innerView.rx.text
            .orEmpty
            .asObservable()
            .map{ String($0.prefix(20)) }
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { (owner, text) in
                owner.nicknameTextField.innerView.text = text
                owner.input.onNext(.textInput(text: text))
            }
            .disposed(by: disposeBag)
    }
}

extension UserEditingViewController {
    @objc func editButtonDidTapped() {
        input.onNext(.editButtonDidTapped)
    }
}

extension UserEditingViewController: BaseViewConfigurable {
    func configureViews() {
        view.backgroundColor = .systemBackground
        
        title = StringKey.editNickname.localized()
        
        view.addSubviews(
            [nicknameLabel, nicknameTextField, validateLabel, editButton]
        )
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
        
        editButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-10)
            make.height.equalTo(60)
        }
    }
}
