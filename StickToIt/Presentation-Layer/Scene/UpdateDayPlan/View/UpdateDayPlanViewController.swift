//
//  UpdateDayPlanViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/11/23.
//

import UIKit

final class UpdateDayPlanViewController: UIViewController {
 
    private let viewModel: UpdateDayPlanViewModel
    
    // MARK: UI Properties
    
//    private let mainView: UIView
    
    let borderContainerView: UIView = {
        let view = UIView()
        view.bordered(cornerRadius: 20, borderWidth: 1, borderColor: .systemIndigo)
        return view
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
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
    
    
    // MARK: Life Cycle
    
    init(viewModel: UpdateDayPlanViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.viewDidLoad()
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
            self.imageView.isHidden = true
            self.imageView.image = UIImage(data: imageData)
        } else {
            self.imageView.isHidden = false
        }
    }
}


extension UpdateDayPlanViewController: BaseViewConfigurable {
    func configureViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(borderContainerView)
        
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
}
