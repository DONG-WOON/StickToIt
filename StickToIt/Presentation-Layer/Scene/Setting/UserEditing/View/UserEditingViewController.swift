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
        view.bordered(borderWidth: 1, borderColor: .assetColor(.accent2))
        return view
    }()
    
    private lazy var editButton: ResizableButton = {
        let button = ResizableButton(
            title: "닉네임 변경하기",
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
            .transform(input: input.asObserver())
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { (_self, event) in
                switch event {
                case .completeEditing:
                    _self.navigationController?.popViewController(animated: true)
                case .userNicknameValidate(let isValidated):
                    _self.editButton.isEnabled = isValidated
                    _self.editButton.backgroundColor = isValidated ? .assetColor(.accent1) : .gray
                    
                case .validateError(let errorMessage):
                    guard let errorMessage else {
                        _self.validateLabel.text = "유효한 닉네임 입니다."
                        _self.validateLabel.textColor = .assetColor(.accent1)
                        return
                    }
                    _self.validateLabel.text = errorMessage
                    _self.validateLabel.textColor = .systemRed
                case .showError(let error):
                    _self.showAlert(title: "오류메세지", message: "닉네임을 변경할 수 없습니다. 다음에 다시 시도해주세요!") {}
                case .updateNickname(let nickname):
                    _self.nicknameTextField.innerView.text = nickname
                }
            }
            .disposed(by: disposeBag)
       
        nicknameTextField.innerView.rx.text
            .orEmpty
            .asObservable()
            .map{ String($0.prefix(20)) }
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { (_self, text) in
                self.nicknameTextField.innerView.text = text
                _self.input.onNext(.textInput(text: text))
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
        
        title = "닉네임 변경"
        
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
