//
//  StaticsViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/23/23.
//

import UIKit
import RxSwift

final class StaticsViewController: UIViewController {
    
    private let viewModel: StaticsViewModel
    
    private let input = PublishSubject<StaticsViewModel.Input>()
    private let disposeBag = DisposeBag()
    
    // MARK: UI Properties
    
    private let containerView = UIView(backgroundColor: .assetColor(.accent4))
    private let plantImageView = UIImageView(image: UIImage(named: "1"))
    private let progressView = GradientCircleView(frame: .zero)
    
    
    // MARK: Life Cycle
    
    init(viewModel: StaticsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        input.onNext(.viewDidLoad)
    }
    
    func bind() {
        
        viewModel
            .transform(input: input)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { owner, event in
                switch event {
                case .configureUI:
                    owner.configureViews()
                    owner.setConstraints()
                case .showProgress(let progress):
                    owner.setPlantImage(progress)
                    owner.progressView.setProgress(progress)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func setPlantImage(_ progress: Double) {
        var level: Int
        switch progress {
        case 0..<0.1:
            level = 1
        case 0.1..<0.3:
            level = 2
        case 0.3..<0.6:
            level = 3
        case 0.6..<0.9:
            level = 4
        case 0.9..<1.0:
            level = 5
        default:
            level = 0
        }
        
        plantImageView.image = UIImage(named: String(level))
    }
}

extension StaticsViewController: BaseViewConfigurable {
    func configureViews() {
        view.backgroundColor = .black.withAlphaComponent(0.3)
        view.addSubview(containerView)
        
        containerView.addBlurEffect()
        
        containerView.addSubviews([plantImageView, progressView])
        
        containerView.bordered(borderWidth: 0.5, borderColor: .assetColor(.accent1))
    }
    
    func setConstraints() {
        
        plantImageView.snp.makeConstraints { make in
            make.top.equalTo(containerView).inset(20)
            make.centerX.equalTo(containerView)
            make.width.equalTo(containerView).multipliedBy(0.6)
            make.bottom.equalTo(progressView.snp.top).offset(-20)
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(view).multipliedBy(0.5)
        }
        
        progressView.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.bottom).inset(30)
            make.centerX.equalTo(containerView)
            make.width.equalTo(containerView).multipliedBy(0.6)
            make.height.equalTo(progressView.snp.width)
        }
    }
}
