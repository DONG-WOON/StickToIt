//
//  FavoritePlanSettingViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import UIKit
import RxSwift
import RxCocoa

final class FavoritePlanSettingViewController: UIViewController {
    
    let viewModel: FavoritePlanSettingViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK: UI Properties
    
    private let tableView = UITableView()
    
    init(viewModel: FavoritePlanSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        setConstraints()
        
        viewModel.fetchPlanQueries()
    }
    
    func bindUI() {
        
        viewModel.planQueries
            .asObserver()
            .bind(to: tableView.rx.items) { tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
                cell.textLabel?.text = item.planName
                return cell
            }
            .disposed(by: disposeBag)
    }
}

extension FavoritePlanSettingViewController: BaseViewConfigurable {
    func configureViews() {
        view.addSubview(tableView)
        
        tableView.allowsMultipleSelection = true
    }
    
    func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
