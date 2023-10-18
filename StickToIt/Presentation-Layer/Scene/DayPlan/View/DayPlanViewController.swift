//
//  DayPlanViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/11/23.
//

import UIKit
import RxSwift

final class DayPlanViewController: UIViewController {
    
    enum ViewState {
        case editing
        case done
    }
    
    private var viewState: ViewState = .done
    
    private let viewModel: CreateDayPlanViewModel<CreateDayPlanUseCaseImpl<DayPlanRepositoryImpl>>
    private let disposeBag = DisposeBag()
    
    // MARK: UI Properties
    
    private let borderContainerView: UIView = {
        let view = UIView()
        view.bordered(cornerRadius: 20, borderWidth: 0.5, borderColor: .assetColor(.accent2))
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        let gesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        view.addGestureRecognizer(gesture)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var blurView: BlurEffectView  = {
        let view = BlurEffectView()
        view.rounded(cornerRadius: 20)
        return view
    }()

    private let dateLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.font = .systemFont(ofSize: 19)
        view.innerView.textColor = .white
        return view
    }()
    
    private lazy var imageContentModeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(
            items: [
                Const.Image.scaleAspectFit,
                Const.Image.scaleAspectFill
            ]
        )
        
        segment.selectedSegmentIndex = 0
        segment.isEnabled = false
        
        segment.setImage(UIImage(named: Const.Image.scaleAspectFit), forSegmentAt: 0)
        segment.setImage(UIImage(named: Const.Image.scaleAspectFill), forSegmentAt: 1)
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        return segment
    }()
    
    private let contentTextView: UITextView = {
        let view = UITextView()
        view.text = "달성한 계획을 간략하게 작성해보세요!"
        return view
    }()
    
    private lazy var addImageButton: UIButton = {
        
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
    
    private lazy var editImageButton: UIButton = {
        
        var configuration = UIButton.Configuration.plain()
        
        configuration.image = UIImage(resource: .pencil)
        configuration.preferredSymbolConfigurationForImage = .init(scale: .large)
        configuration.baseForegroundColor = .white
        
        let view = UIButton(configuration: configuration)
        view.isHidden = true
        view.addTarget(self, action: #selector(editImageButtonAction), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var requiredLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.text = "필수"
        view.innerView.textColor = .white
        view.innerView.textAlignment = .center
        view.rounded(cornerRadius: 16)
        view.backgroundColor = .assetColor(.accent2)
        return view
    }()
    
    private let checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.tintColor = .assetColor(.accent2)
        imageView.image = UIImage(resource: .checkedCircle)
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var certifyButton: ResizableButton = {
        let button = ResizableButton(
            title: "당일만 인증할 수 있어요.",
            font: .boldSystemFont(ofSize: 20),
            tintColor: .white,
            backgroundColor: .assetColor(.accent1),
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
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setTitle("편집", for: .normal)
        button.setTitle("완료", for: .selected)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.assetColor(.accent1), for: .selected)
        button.addTarget(self, action: #selector(dayPlanEdit), for: .touchUpInside)
        return button
    }()
    
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
        addNotification()
        configureViews()
        setConstraints()
        bind()
    }
    
    func bind() {
        
        if let _date = viewModel.dayPlan.date {
            let dateString = DateFormatter.getFullDateString(from: _date)
            self.dateLabel.innerView.text = dateString
            
            if DateFormatter.getFullDateString(from: .now) == dateString {
                certifyButton.isHidden = false
                if viewModel.dayPlan.isComplete {
                    certifyButton.setTitle("인증 완료 ✨", for: .normal)
                }
            } else {
                certifyButton.isHidden = true
            }
        }
        
        imageView.contentMode = viewModel.dayPlan.imageContentIsFill ? .scaleAspectFill : .scaleAspectFit
        requiredLabel.isHidden = !viewModel.dayPlan.isRequired
        
        checkMarkImageView.isHidden = !viewModel.dayPlan.isComplete
        editButton.isHidden = !viewModel.dayPlan.isComplete
        
        
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        
        view.addSubview(borderContainerView)
        
        view.addSubview(imageContentModeSegment)
        
        imageContentModeSegment.selectedSegmentIndex = 0
        
        
        borderContainerView.addSubview(imageView)
        borderContainerView.addSubview(blurView)
        borderContainerView.addSubview(addImageButton)
        
        blurView.addSubview(requiredLabel)
        blurView.addSubview(dateLabel)
        blurView.addSubview(editImageButton)
        blurView.addSubview(checkMarkImageView)
        
        view.addSubview(certifyButton)
        view.addSubview(indicatorView)
    
    }
    
    func setConstraints() {
        
        borderContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.9)
            make.height.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.7)
        }
        
        imageContentModeSegment.snp.makeConstraints { make in
            make.bottom.equalTo(imageView.snp.top).offset(-10)
            make.trailing.equalTo(imageView)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(borderContainerView)
        }
        
        blurView.snp.makeConstraints { make in
            make.bottom.equalTo(borderContainerView).inset(15)
            make.horizontalEdges.equalTo(borderContainerView).inset(15)
            make.height.equalTo(50)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(blurView).inset(10)
            make.centerY.equalTo(blurView)
        }
        
        requiredLabel.snp.makeConstraints { make in
            make.trailing.equalTo(blurView).inset(10)
            make.centerY.equalTo(blurView)
        }
        
        checkMarkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalTo(blurView)
            make.leading.equalTo(dateLabel.snp.trailing).offset(10)
        }
        
        addImageButton.snp.makeConstraints { make in
            make.centerX.equalTo(imageView)
            make.centerY.equalTo(imageView).offset(20)
        }
        
        editImageButton.snp.makeConstraints { make in
            make.centerY.equalTo(blurView)
            make.trailing.equalTo(blurView).inset(10)
        }
        
        certifyButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-10)
        }
        
        indicatorView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
}


extension DayPlanViewController {
    
    @objc func imageViewTapped(_ gesture: UITapGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            print("began")
        case.changed:
            print("changed")
        case .cancelled:
            print("cancel")
        case .possible:
            print("possible")
        case .failed:
            print("failed")
        case .ended:
            print("end")
        @unknown default:
            return
        }
        print(gesture.location(in: imageView))
        
        
        let textView = PaddingView<UITextView>()
        textView.rounded()
        textView.innerView.delegate = self
        textView.backgroundColor = .white.withAlphaComponent(0.6)
        textView.innerView.backgroundColor = .clear
        textView.innerView.textColor = .black
        textView.center = gesture.location(in: imageView)
        
        imageView.addSubview(textView)
    }
}

extension DayPlanViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.sizeToFit()
    }
}

extension DayPlanViewController {
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateImageToUpload), name: .updateImageToUpload, object: nil)
    }

    @objc private func dayPlanEdit(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if sender.isSelected {
            viewState = .editing
            imageContentModeSegment.isEnabled = true
            imageContentModeSegment.selectedSegmentTintColor = .assetColor(.accent2)
            editImageButton.isHidden = false
        } else {
            viewState = .done
            
            imageContentModeSegment.isEnabled = false
            imageContentModeSegment.selectedSegmentTintColor = .systemBackground
            editImageButton.isHidden = true
            
            #warning("수정사항 업데이틑 하기")
        }
    }
    
    @objc private func editImageButtonAction() {
        
        // 이미지 수정, 이미지 재선택,
        
        let vc = ImageSelectionViewController(imageManager: ImageManager())
            .embedNavigationController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            imageView.contentMode = .scaleAspectFit
            viewModel.dayPlan.imageContentIsFill = false
        case 1:
            imageView.contentMode = .scaleAspectFill
            viewModel.dayPlan.imageContentIsFill = true
        default:
            return
        }
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
        self.imageContentModeSegment.isEnabled = true
        self.editImageButton.isHidden = false
        self.viewModel.isValidated.accept(true)
    }
    
    @objc private func createButtonDidTapped() {
        /*⭐️ 나의 의견
         이미지를 매번 홈화면에서 렌더링 하는것보다 이미지를 불러올때,
         원본사진을 렌더링하고, 해당 렌더링 된 이미지를 리사이징(압축)하여 데이터로 저장한다.
         그리고 홈화면에서 이미지를 불러올때는 해당 데이터를 가공없이 불러오면 문제 없을 것으로 예상됨.
         */
        
        //1 이미지 파일 압축 (무손실 압축은 1.0) 백그라운드에서
        viewModel.isLoading(true)
        
        Task(priority: .background) { [weak self] in
            guard let _self = self else { return }
            let originalImage = _self.imageView.image
            let result = await _self.viewModel.save(with: originalImage)
            
            switch result {
            case .success:
                NotificationCenter.default.post(name: .reloadPlan, object: nil)
                DispatchQueue.main.async {
                    _self.viewModel.isLoading(false)
                    _self.dismiss(animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    _self.viewModel.isLoading(false)
                }
                print(error)
            }
        }
    }
    
    @objc private func dismissButtonDidTapped() {
        
        switch viewState {
        case .done:
            self.dismiss(animated: true)
        case .editing:
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
}
