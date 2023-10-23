//
//  DayPlanViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/11/23.
//

import UIKit
import RxSwift

final class DayPlanViewController: UIViewController {
    
    private let viewModel: CreateDayPlanViewModel<CreateDayPlanUseCaseImpl<DayPlanRepositoryImpl>>
    private let disposeBag = DisposeBag()
    
    // MARK: UI Properties
    
    private let borderContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .assetColor(.accent4).withAlphaComponent(0.3)
        view.rounded()
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.rounded()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var blurView: BlurEffectView  = {
        let view = BlurEffectView()
        view.rounded()
        return view
    }()
    
    private lazy var weekDayLabel: PaddingView<UILabel> = {
       let paddingView = PaddingView<UILabel>()
        paddingView.innerView.text = "1주차"
        paddingView.innerView.font = .monospacedSystemFont(ofSize: FontSize.body, weight: .semibold)
        paddingView.innerView.backgroundColor = .clear
        paddingView.backgroundColor = .assetColor(.accent4)
        paddingView.rounded(cornerRadius: 20)
        paddingView.addBlurEffect()
        return paddingView
    }()

    private let dateLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.font = .systemFont(ofSize: 19)
        view.innerView.textColor = .white
        return view
    }()
    
    private lazy var addImageButton: UIButton = {
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = "사진 추가"
        configuration.image = UIImage(resource: .plus)
        configuration.titleAlignment = .center
        configuration.preferredSymbolConfigurationForImage = .init(scale: .large)
        configuration.imagePlacement = .top
        configuration.imagePadding = 10
        configuration.baseForegroundColor = .black
        
        let view = UIButton(configuration: configuration)
        view.addTarget(self, action: #selector(addImageButtonAction), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var requiredLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.text = "필수"
        view.innerView.textColor = .white
        view.innerView.textAlignment = .center
        view.rounded()
        view.backgroundColor = .assetColor(.accent2)
        return view
    }()
    
    private let checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.tintColor = .systemGreen
        imageView.image = UIImage(resource: .checkedCircle)
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var certifyButton: ResizableButton = {
        let button = ResizableButton(
            font: .boldSystemFont(ofSize: 20),
            tintColor: .white,
            backgroundColor: .assetColor(.accent1),
            target: self,
            action: #selector(certifyButtonDidTapped)
        )
        button.rounded()
        return button
    }()
    
    private lazy var dismissButton = ResizableButton(
        image: UIImage(resource: .xmark),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, target: self,
        action: #selector(dismissButtonDidTapped)
    )
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.isHidden = true
        return view
    }()
    
    
    // MARK: Life Cycle
    
    init(dayPlan: DayPlan) {
        viewModel = CreateDayPlanViewModel(
            dayPlan: dayPlan,
            useCase: CreateDayPlanUseCaseImpl(
                repository: DayPlanRepositoryImpl(
                    networkService: nil,
                    databaseManager: DayPlanDataBaseManager())
            )
        )
        
        super.init(nibName: nil, bundle: nil)
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.checkError { [weak self] key, message in
            if key == Const.Key.isCertifyingError {
                self?.showAlert(title: "인증오류", message: message) {
                    self?.addImageButton.isEnabled = true
                    self?.certifyButton.setTitle("인증하기 ✨", for: .normal)
                }
            } else {
                self?.showAlert(title: "사진 저장 오류", message: message) {
                    self?.addImageButton.isEnabled = true
                    self?.certifyButton.setTitle("인증하기 ✨", for: .normal)
                }
            }
        }
        
        viewModel.viewDidLoad()
        addNotification()
        configureViews()
        setConstraints()
    }
    
    func bind() {
        
        let _date = viewModel.dayPlan.date
        let dateString = DateFormatter.getFullDateString(from: _date)
        self.dateLabel.innerView.text = dateString
        
        if !viewModel.dayPlan.isComplete {
            if DateFormatter.getFullDateString(from: .now) == dateString {
                addImageButton.isEnabled = true
                certifyButton.setTitle("인증하기 ✨", for: .normal)
            } else if DateFormatter.getFullDateString(from: .now) > dateString {
                addImageButton.isEnabled = false
                addImageButton.configuration?.image = UIImage(named: "Placeholder")
                addImageButton.configuration?.title = nil
                certifyButton.setTitle("아쉽게도 인증 못했어요 🥲", for: .normal)
            } else if DateFormatter.getFullDateString(from: .now) < dateString {
                addImageButton.isEnabled = false
                addImageButton.configuration?.image = UIImage(named: "Placeholder")
                addImageButton.configuration?.title = nil
                certifyButton.setTitle("지금처럼 꾸준히 해주세요!", for: .normal)
            }
        } else {
            addImageButton.isEnabled = false
            certifyButton.setTitle("인증 완료 ✨", for: .normal)
        }
        
        requiredLabel.isHidden = !viewModel.dayPlan.isRequired
        
        checkMarkImageView.isHidden = !viewModel.dayPlan.isComplete
        
        weekDayLabel.innerView.text = "\(viewModel.dayPlan.week)주차"
        
        viewModel.loadImage { [weak self] data in
            if let imageData = data {
                self?.addImageButton.isHidden = true
                self?.imageView.image = UIImage(data: imageData)
            } else {
                self?.addImageButton.isHidden = false
            }
        }
        
        viewModel.isValidated
            .subscribe(with: self) { (_self, isValidated) in
                _self.certifyButton.isEnabled = isValidated
                _self.certifyButton.backgroundColor = isValidated ? .assetColor(.accent1) : .gray
            }
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { (_self, isLoading) in
                if isLoading {
                    _self.indicatorView.startAnimating()
                } else {
                    _self.indicatorView.stopAnimating()
                }
                _self.indicatorView.isHidden = !isLoading
            }
            .disposed(by: disposeBag)
    }
}


extension DayPlanViewController: BaseViewConfigurable {
    func configureViews() {
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        
        view.addSubviews(
            [borderContainerView, certifyButton, indicatorView]
        )
        borderContainerView.addSubviews(
            [imageView, blurView, addImageButton, weekDayLabel]
        )
        blurView.addSubviews(
            [requiredLabel, dateLabel, checkMarkImageView]
        )
    }
    
    func setConstraints() {
        
        borderContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(50)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.9)
            make.bottom.equalTo(certifyButton.snp.top).offset(-60)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(borderContainerView).offset(4)
            make.horizontalEdges.equalTo(blurView)
        }
        
        weekDayLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(borderContainerView).inset(10)
        }
        
        blurView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.horizontalEdges.bottom.equalTo(borderContainerView).inset(4)
            make.height.equalTo(50)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(blurView).inset(10)
            make.centerY.equalTo(blurView)
        }
        
        requiredLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalTo(blurView).inset(4)
        }
        
        checkMarkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalTo(blurView)
            make.leading.equalTo(dateLabel.snp.trailing).offset(15)
        }
        
        addImageButton.snp.makeConstraints { make in
            make.centerX.equalTo(imageView)
            make.centerY.equalTo(imageView).offset(20)
            make.width.height.equalTo(imageView.snp.width).multipliedBy(0.3)
        }
        
        certifyButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.horizontalEdges.equalTo(borderContainerView)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-30)
        }
        
        indicatorView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension DayPlanViewController {
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateImageToUpload), name: .updateImageToUpload, object: nil)
    }
    
    @objc private func editImageButtonAction() {
        
        let vc = ImageSelectionViewController(imageManager: ImageManager())
            .embedNavigationController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc private func addImageButtonAction() {
        let vc = ImageSelectionViewController(imageManager: ImageManager())
            .embedNavigationController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc private func updateImageToUpload(_ notification: Notification) {
        guard let image = notification.userInfo?[Const.NotificationKey.imageToUpload] as? UIImage else { return }
        
        self.imageView.image = image
        self.imageView.isUserInteractionEnabled = true
        self.addImageButton.isHidden = true
        self.viewModel.isValidated.accept(true)
    }
    
    @objc private func certifyButtonDidTapped() {
        /*⭐️ 나의 의견
         이미지를 매번 홈화면에서 렌더링 하는것보다 이미지를 불러올때,
         원본사진을 렌더링하고, 해당 렌더링 된 이미지를 리사이징(압축)하여 데이터로 저장한다.
         그리고 홈화면에서 이미지를 불러올때는 해당 데이터를 가공없이 불러오면 문제 없을 것으로 예상됨.
         */
        
        //1 이미지 파일 압축 (무손실 압축은 1.0) 백그라운드에서
        
        viewModel.certifyButtonDidTapped(with: imageView.image) { [weak self] in
            self?.viewModel.isLoading(false)
            self?.dismiss(animated: true)
        } failure: { [weak self] title, message in
            self?.viewModel.isLoading(false)
            self?.showAlert(title: title, message: message) {
                self?.certifyButtonDidTapped()
            }
        }

    }
    
    @objc private func dismissButtonDidTapped() {
        self.dismiss(animated: true)
    }
}
