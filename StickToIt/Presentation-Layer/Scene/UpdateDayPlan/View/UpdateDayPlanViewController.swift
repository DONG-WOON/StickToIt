//
//  UpdateDayPlanViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/11/23.
//

import UIKit

final class UpdateDayPlanViewController: UIViewController {
    
    private let viewModel: UpdateDayPlanViewModel<UpdatePlanUseCaseImpl<DayPlanRepositoryImpl>>
    
    // MARK: UI Properties
    
    //    private let mainView: UIView
    
    let borderContainerView: UIView = {
        let view = UIView()
        view.bordered(cornerRadius: 20, borderWidth: 1, borderColor: .systemIndigo)
        return view
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.borderColor = UIColor.systemIndigo.cgColor
        view.layer.borderWidth = 0.4
        return view
    }()
    
    let dateLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.font = .systemFont(ofSize: 17)
        view.innerView.textColor = .label
        view.backgroundColor = .tertiaryLabel.withAlphaComponent(0.05)
        return view
    }()
    
    let contentTextView: UITextView = {
        let view = UITextView()
        view.text = "달성한 계획을 간략하게 작성해보세요!"
        return view
    }()
    
    lazy var addImageButton: UIButton = {
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = "사진 추가"
        configuration.image = UIImage(resource: .plus)
        configuration.preferredSymbolConfigurationForImage = .init(scale: .large)
        configuration.imagePlacement = .top
        configuration.imagePadding = 10
        configuration.baseForegroundColor = .label
        
        let view = UIButton(configuration: configuration)
        view.addTarget(self, action: #selector(addImageButtonAction), for: .touchUpInside)
        
        return view
    }()
    
    lazy var editImageButton: UIButton = {
        
        var configuration = UIButton.Configuration.plain()
        
        configuration.image = UIImage(resource: .pencil)
        configuration.preferredSymbolConfigurationForImage = .init(scale: .large)
        configuration.baseForegroundColor = .label
        
        let view = UIButton(configuration: configuration)
        view.addTarget(self, action: #selector(editImageButtonAction), for: .touchUpInside)
        
        return view
    }()
    
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
    
    private lazy var dismissButton = ResizableButton(
        image: UIImage(resource: .xmark),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, target: self,
        action: #selector(dismissButtonDidTapped)
    )
    
    
    // MARK: Life Cycle
    
    init(dayPlan: DayPlan) {
        viewModel = UpdateDayPlanViewModel(
            dayPlan: dayPlan,
            useCase: UpdatePlanUseCaseImpl(
                repository: DayPlanRepositoryImpl(
                    networkService: nil,
                    databaseManager: DayPlanDataBaseManager())
            )
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateImageToUpload), name: .updateImageToUpload, object: nil)
        
        configureViews()
        setConstraints()
        bind()
    }
    
    func bind() {
        if let date = viewModel.dayPlan.date {
            self.dateLabel.innerView.text = DateFormatter.dayPlanFormatter.string(from: date)
        } else {
            self.dateLabel.innerView.text = DateFormatter.dayPlanFormatter.string(from: .now)
        }
        
        if let imageData = viewModel.dayPlan.imageData {
            self.addImageButton.isHidden = true
            self.editImageButton.isHidden = false
            self.imageView.image = UIImage(data: imageData)
        } else {
            self.addImageButton.isHidden = false
            self.editImageButton.isHidden = true
        }
    }
}


extension UpdateDayPlanViewController: BaseViewConfigurable {
    func configureViews() {
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        view.addSubview(borderContainerView)
        view.addSubview(editImageButton)
        view.addSubview(createButton)
        
        borderContainerView.addSubview(imageView)
        borderContainerView.addSubview(dateLabel)
        borderContainerView.addSubview(addImageButton)
        
        
    }
    
    func setConstraints() {
        
        borderContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(50)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.7)
            make.height.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.5)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(borderContainerView)
            make.height.equalTo(borderContainerView).multipliedBy(0.8)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(borderContainerView)
        }
        
        addImageButton.snp.makeConstraints { make in
            make.centerX.equalTo(imageView)
            make.centerY.equalTo(imageView).offset(20)
        }
        editImageButton.snp.makeConstraints { make in
            make.bottom.equalTo(borderContainerView.snp.top).offset(-10)
            make.trailing.equalTo(borderContainerView)
        }
        
        createButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-10)
        }
    }
}


extension UpdateDayPlanViewController {
    
    @objc private func editImageButtonAction() {
        //        self.delegate?.editImageButtonDidTapped()
    }
    //
    @objc private func addImageButtonAction() {
        let vc = ImageSelectionViewController(imageManager: ImageManager())
            .embedNavigationController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc private func updateImageToUpload(_ notification: Notification) {
        let image = notification.userInfo?[Const.Key.imageToUpload] as? UIImage
        self.imageView.image = image
        
        if image != nil {
            self.addImageButton.isHidden = true
            self.editImageButton.isHidden = false
        } else {
            self.addImageButton.isHidden = false
            self.editImageButton.isHidden = true
        }
    }
    
    @objc private func createButtonDidTapped() {
        viewModel.dayPlan.imageData = imageView.image?.pngData()
        viewModel.save { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    @objc private func dismissButtonDidTapped() {
        let alert = UIAlertController(title: "주의", message: "지금 나가면 편집 내용이 사라질 수 도 있습니다. 나가시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "나가기", style: .destructive) { _ in
            self.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
}
