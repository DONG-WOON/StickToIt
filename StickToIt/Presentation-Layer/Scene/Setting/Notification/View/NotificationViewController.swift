//
//  NotificationViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/30/23.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationViewController: UIViewController {
    
    private let viewModel: NotificationViewModel
    private let input = PublishSubject<NotificationViewModel.Input>()
    private let disposeBag = DisposeBag()
    
    // MARK: UI Properties
    
    let mainView = NotificationView()
    
    init(viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestNotificationAuthorization()
        input.onNext(.viewDidLoad)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        input.onNext(.viewWillDisappear)
    }
    
    func bind() {
        viewModel
            .transform(input: input)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { owner, event in
                switch event {
                case .setUpTableView(let notiInfo):
                    owner.setupTableView(with: notiInfo)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension NotificationViewController {
    func setupTableView(with notiInfo: (isAllowed: Bool, time: Date?)) {
        
        Observable.just([0,1])
            .bind(to: mainView.rx.items(
                cellIdentifier: NotificationViewCell.identifier,
                cellType: NotificationViewCell.self)
            ) { [weak self] row, item, cell in
                
                if row == 0 {
                    cell.setUpSwitchRow(isOn: notiInfo.isAllowed) { [weak self] isAllowed in
                        (self?.mainView.cellForRow(at: IndexPath(row: 1, section: 0)) as? NotificationViewCell)?.isHidden = !isAllowed
                        self?.viewModel.switchChanged(isAllowed)
                    }
                }
                
                if row == 1 {
                    cell.isHidden = !notiInfo.isAllowed
                    cell.setUpPickerRow(time: notiInfo.time) { [weak self] time in
                        self?.viewModel.dateChanged(time)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    func requestNotificationAuthorization() {
        NotificationManager.shared.requestAuthorization()
    }
}
