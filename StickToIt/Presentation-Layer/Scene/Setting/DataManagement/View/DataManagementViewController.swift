//
//  DataManagementViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/30/23.
//

import UIKit
import RxSwift

final class DataManagementViewController: UIViewController {

    private let viewModel: DataManagementViewModel
    private let input = PublishSubject<DataManagementViewModel.Input>()
    private let disposeBag = DisposeBag()
    
    // MARK: UI Properties
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // MARK: Life Cycle
    
    init(viewModel: DataManagementViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        setConstraints()
    }
    
    func bind() {
        viewModel
            .transform(input: input.asObserver())
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { _self, event in
                switch event {
                case .completeDeleteUser:
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    let sceneDelegate = windowScene?.delegate as? SceneDelegate
                    let window = sceneDelegate?.window
                    let mainVC = UserSettingViewController(viewModel: DIContainer.makeUserSettingViewModel())
                    
                    window?.rootViewController = mainVC
                    window?.makeKeyAndVisible()
                    
                    if let window {
                        UIView.transition(with: window,
                                          duration: 0.6,
                                          options: .transitionCrossDissolve,
                                          animations: nil)
                    }
                case .completeBackUP:
                    return
                case .showError:
                    _self.showAlert(title: "삭제 오류", message: "사용자의 정보를 삭제할 수 없습니다. 앱을 삭제 후 다시 설치해주세요!")
                }
            }
            .disposed(by: disposeBag)
    }
}

extension DataManagementViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataManagementViewCell", for: indexPath)
        var configuration = cell.defaultContentConfiguration()
        configuration.text = viewModel.rowTitle(at: indexPath)
        configuration.textProperties.font = .systemFont(ofSize: Const.FontSize.body, weight: .regular)
        if viewModel.isDeleteUser(at: indexPath) {
            configuration.textProperties.color = .red
        }
        
        cell.contentConfiguration = configuration
        cell.contentView.backgroundColor = .assetColor(.accent4).withAlphaComponent(0.3)
        
        return cell
    }
}

extension DataManagementViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.selectedRowAt(indexPath) { [weak self] row in
            switch row {
//            case .backup:
//                return
            case .deleteUser:
                self?.alert(title: StringKey.delete.localized(), message: StringKey.deleteUserMessage.localized()) { [weak self] in
                    self?.input.onNext(.deleteUser)
                }
            }
        }
    }
    
    func alert(title: String, message: String, okAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: StringKey.yes.localized(), style: .destructive) { _ in
            okAction?()
        }
        let cancelAction = UIAlertAction(title: StringKey.no.localized(), style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
}

extension DataManagementViewController: BaseViewConfigurable {
    
    private func settingTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DataManagementViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
    }
    
    func configureViews() {
        view.backgroundColor = .systemBackground
        
        settingTableView()
        
        view.addSubview(tableView)
    }
    
    func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
