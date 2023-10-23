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
            .transform(input: input.asObserver())
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { _self, event in
                switch event {
                case .configureUI:
                    _self.configureViews()
                    _self.setConstraints()
                case .showProgress(let progress):
                    _self.progressView.setProgress(progress)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension StaticsViewController: BaseViewConfigurable {
    func configureViews() {
        view.backgroundColor = .black.withAlphaComponent(0.3)
        view.addSubview(containerView)
        
        containerView.backgroundColor = .white
        
        containerView.addSubviews([progressView])
        
        containerView.bordered(borderWidth: 0.5, borderColor: .assetColor(.accent1))
    }
    
    func setConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(view).multipliedBy(0.5)
        }
        
        progressView.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.bottom).inset(20)
            make.centerX.equalTo(containerView)
            make.width.equalTo(containerView).multipliedBy(0.6)
            make.height.equalTo(progressView.snp.width)
        }
    }
}
