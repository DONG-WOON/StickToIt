//
//  EditImageViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/10/23.
//

import UIKit
import RxSwift

final class EditImageViewController: UIViewController {
    
    private let viewModel = EditImageViewModel(
        useCase: EditImageUseCaseImpl(
            repository: PlanRepositoryImpl(
                networkService: nil,
                databaseManager: PlanDatabaseManager()
            )
        )
    )
    private var addedTextViews: [Int: UITextView] = [:]
    private let textViewBackgroundColorChanged = PublishSubject<UIColor?>()
    private let textViewColorChanged = PublishSubject<UIColor?>()
    private let textViewFontChanged = PublishSubject<UIFont>()
    
    private let input = PublishSubject<EditImageViewModel<EditImageUseCaseImpl<PlanRepositoryImpl>>.Input>()
    private let disposeBag = DisposeBag()
    
    
    // frame 내부
    
    let frameView: UIView = {
        let view = UIView()
        view.rounded()
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "images"))
        view.backgroundColor = .white
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var trashView: UIImageView = {
        let view = UIImageView(image: UIImage(resource: .trash))
        view.rounded(cornerRadius: 30)
        view.backgroundColor = .white
        view.tintColor = .darkGray
        view.isHidden = true
        return view
    }()
    
    private let timeView: BlurEffectView = {
        let view = BlurEffectView()
        view.rounded(cornerRadius: 20)
        view.isHidden = true
        return view
    }()
    
    private let timeLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 19)
        view.textColor = .white
        return view
    }()
    
    
    // frame 외부
    
    private lazy var aspectRatioButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .aspectratio)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .assetColor(.accent2)
        button.rounded(cornerRadius: 30)
        button.addTarget(self, action: #selector(aspectRatioButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var textFormatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .textformat)?.withRenderingMode( .alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .assetColor(.accent2)
        button.rounded(cornerRadius: 30)
        button.addTarget(self, action: #selector(textFormatButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var textColorButton: UIButton = {
        let view = UIButton()
        view.bordered(cornerRadius: 30 ,borderWidth: 1, borderColor: .assetColor(.accent1))
        view.backgroundColor = .white
        view.addTarget(self, action: #selector(colorChanged), for: .touchUpInside)
        return view
    }()
    
    private lazy var timeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .timer)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .assetColor(.accent2)
        button.rounded(cornerRadius: 30)
        button.addTarget(self, action: #selector(timerButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    let fontSizeLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.text = "글자 크기"
        view.innerView.textColor = .label
        view.innerView.textAlignment = .left
        view.innerView.font = .systemFont(ofSize: 17, weight: .semibold)
        view.bordered(cornerRadius: 20, borderWidth: 0.5)
        view.backgroundColor = .assetColor(.accent4).withAlphaComponent(0.3)
        return view
    }()
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 17
        slider.maximumValue = 32
        slider.setValue(22, animated: false)
        slider.thumbTintColor = .assetColor(.accent1)
        slider.minimumTrackTintColor = .assetColor(.accent2)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    private lazy var editCompleteButton = ResizableButton(
        title: "사진 올리기",
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, target: self,
        action: #selector(editCompleteButtonDidTapped)
    )
    
    // MARK: Life Cycle
    
//    init(viewModel: EditImageViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//
//        bind()
//    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input.onNext(.viewDidLoad)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    private func bind() {
        viewModel
            .transform(input: input.asObserver())
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { _self, event in
                switch event {
                case .ConfigureUI:
                    _self.configureViews()
                    _self.setConstraints()
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: Methods
    
    private func capture(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: Button Actions

extension EditImageViewController {
    
    @objc private func editCompleteButtonDidTapped() {
        addedTextViews.removeAll()
        view.endEditing(true)
//        let snapshot = frameView.snapshotView(afterScreenUpdates: true)
        
        NotificationCenter.default.post(name: .updateImageToUpload, object: nil, userInfo: [NotificationKey.imageToUpload: capture(view: frameView) ?? UIImage()])

        self.dismiss(animated: true)
    }
    
    @objc private func aspectRatioButtonDidTapped(_ sender: UIButton) {
        imageView.contentMode = imageView.contentMode == .scaleAspectFill ? .scaleAspectFit : .scaleAspectFill
    }
    
    @objc private func textFormatButtonDidTapped(_ sender: UIButton) {
        addTextView()
    }
    
    @objc private func timerButtonDidTapped(_ sender: UIButton) {
        timeLabel.text = DateFormatter.getTimeString(from: .now)
        timeView.isHidden.toggle()
    }
    
    @objc private func colorChanged(_ sender: UIButton) {
        let picker = UIColorPickerViewController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        textViewFontChanged.onNext(.systemFont(ofSize: CGFloat(sender.value)))
    }
}

extension EditImageViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        guard let components = viewController.selectedColor.cgColor.components else { return }
        
        if components[0] > 0.7 && components[1] > 0.7 && components[2] > 0.7 {
            //배경 블랙
            textViewBackgroundColorChanged.onNext( .darkGray.withAlphaComponent(0.8))
        } else {
            //배경 흰색
            textViewBackgroundColorChanged.onNext(.white.withAlphaComponent(0.8))
        }
        
        textViewColorChanged.onNext(viewController.selectedColor)
    }
}


extension EditImageViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textView.text = viewModel.filtered(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return viewModel.textViewShouldChanged(textView.text, in: range, word: text)
    }
}

extension EditImageViewController: BaseViewConfigurable {
    func configureViews() {
        view.backgroundColor = .assetColor(.accent4)
        
        view.addSubviews(
            [frameView,
             textFormatButton, aspectRatioButton, timeButton,
             textColorButton,
             fontSizeLabel]
        )
        
        frameView.addSubviews([imageView, timeView, trashView])
        
        fontSizeLabel.addSubview(slider)
        timeView.addSubview(timeLabel)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editCompleteButton)
    }
    
    func setConstraints() {
        /// frame 내부
        
        frameView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(50)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.82)
            make.height.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.6)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(frameView)
        }
        
        trashView.snp.makeConstraints { make in
            make.centerX.equalTo(frameView)
            make.bottom.equalTo(frameView).inset(20)
            make.height.width.equalTo(60)
        }
        
        timeView.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(imageView).inset(10)
            make.height.equalTo(40)
            make.width.equalTo(imageView).multipliedBy(0.5)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.center.equalTo(timeView)
        }
        
        /// frame 외부
        
        aspectRatioButton.snp.makeConstraints { make in
            make.top.equalTo(frameView.snp.bottom).offset(20)
            make.trailing.equalTo(frameView.snp.centerX).offset(-5)
            make.width.height.equalTo(60)
        }
        
        textFormatButton.snp.makeConstraints { make in
            make.top.equalTo(frameView.snp.bottom).offset(20)
            make.trailing.equalTo(aspectRatioButton.snp.leading).offset(-10)
            make.width.height.equalTo(60)
        }
        
        timeButton.snp.makeConstraints { make in
            make.top.equalTo(frameView.snp.bottom).offset(20)
            make.leading.equalTo(frameView.snp.centerX).offset(5)
            make.width.height.equalTo(60)
        }
        
        textColorButton.snp.makeConstraints { make in
            make.top.equalTo(frameView.snp.bottom).offset(20)
            make.leading.equalTo(timeButton.snp.trailing).offset(10)
            make.width.height.equalTo(60)
        }
        
        fontSizeLabel.snp.makeConstraints { make in
            make.top.equalTo(textColorButton.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(frameView)
            make.height.equalTo(40)
        }
        
        slider.snp.makeConstraints { make in
            make.centerY.equalTo(fontSizeLabel.snp.centerY)
            make.width.equalTo(fontSizeLabel).multipliedBy(0.7)
            make.trailing.equalTo(fontSizeLabel).inset(10)
            make.height.equalTo(30)
        }
    }
}

extension EditImageViewController {
    
    func addTextView() {
        
        let textView = {
            let view = UITextView()
            view.backgroundColor = .darkGray.withAlphaComponent(0.8)
            view.textColor = .white
            view.font = .systemFont(ofSize: 22)
            view.isScrollEnabled = false
            view.textAlignment = .center
            view.textContainer.lineFragmentPadding = 20.0
            view.delegate = self
            view.rounded()
            return view
        }()
        
        frameView.addSubview(textView)
       
        textView.snp.makeConstraints { make in
            make.center.equalTo(frameView)
            make.width.height.lessThanOrEqualTo(frameView).multipliedBy(0.8)
        }
        
        textViewColorChanged
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: textView) { [weak self] _textView, color in
                _textView.textColor = color
                self?.textColorButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        textViewBackgroundColorChanged
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: textView) { _textView, color in
                _textView.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        textViewFontChanged
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: textView) { _textView, font in
                _textView.font = font
            }
            .disposed(by: disposeBag)
        
        let textViewEndIndex = addedTextViews.keys.endIndex
        textView.tag = textViewEndIndex.hashValue
        
        addedTextViews[textView.tag] = textView
        
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(pan)
        )
        
        let rotationGesture = UIRotationGestureRecognizer(
            target: self,
            action: #selector(rotation)
        )
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(tap)
        )
        
        registerTo(
            textView,
            gestures: [
                panGesture,
                rotationGesture,
                tapGesture
            ]
        )
        
        textView.becomeFirstResponder()
    }
    
    private func registerTo(_ textView: UITextView, gestures: [UIGestureRecognizer]) {
        textView.isUserInteractionEnabled = true
        gestures.forEach { textView.addGestureRecognizer($0) }
    }
}

extension EditImageViewController {
    
    private func isContains(point: CGPoint, inView frameView: UIView?) -> Bool {
        guard let frameView else { return false }
        return frameView.frame.contains(point)
    }
}


// MARK: UI Gesture

extension EditImageViewController {
    
    @objc func tap(_ gesture: UITapGestureRecognizer) {
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
            if let textView = (gesture.view as? UITextView) {
                textView.becomeFirstResponder()
            }
            print("sefsefsef")
        @unknown default:
            return
        }
    }
    
    @objc func pan(_ gesture: UIPanGestureRecognizer) {
    
        switch gesture.state {
        case .began:
            print("began")
            trashView.isHidden = false
        case.changed:
            guard let gestureView = gesture.view else { return }
            let transition = gesture.translation(in: frameView)
            gestureView.center = CGPoint(x: gestureView.center.x + transition.x, y: gestureView.center.y + transition.y)
            
            gesture.setTranslation(.zero, in: frameView)

            if isContains(point: gestureView.center, inView: trashView) {
                UIView.animate(withDuration: 0.6) {
                    self.trashView.transform = CGAffineTransform.identity.scaledBy(x: 1.3, y: 1.3)
                    gestureView.transform = CGAffineTransform.identity.scaledBy(x: 0, y: 0)
                }
            } else {
                UIView.animate(withDuration: 0.6) {
                    self.trashView.transform = .identity
                    gestureView.transform = .identity
                }
            }
            
        case .cancelled:
            print("cancel")
        case .possible:
            print("possible")
        case .failed:
            print("failed")
        case .ended:
            guard let gestureView = gesture.view else { return }

            if isContains(point: gestureView.center, inView: trashView) {
                guard let tag = gesture.view?.tag else { return }
                addedTextViews[tag] = nil
                gesture.view?.removeFromSuperview()
            }
            
            trashView.isHidden = true
        @unknown default:
            return
        }
    }
    
    @objc func rotation(_ gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .began:
            print("began")
        case.changed:
            gesture.view?.transform = CGAffineTransform.identity
                            .rotated(by: gesture.rotation)
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
    }
}

