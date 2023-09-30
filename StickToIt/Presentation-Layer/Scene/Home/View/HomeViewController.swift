//
//  HomeViewController.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case main = 0
        case last
    }
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    typealias HomeDataSource = UICollectionViewDiffableDataSource<Section, String>
    
    let viewModel = HomeViewModel(
        showPlanUseCase: DefaultShowPlanUseCase(
            planRepository: DefaultPlanRepository(
                networkService: nil,
                databaseManager: PlanDatabaseManager(
                    queue: .init(label: "default.serial")
                )
            )
        )
    )
    
    private var disposeBag = DisposeBag()
    
    // MARK: UI Properties
    private lazy var planListButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: Const.Image.listBullet)
        configuration.baseForegroundColor = .label
        
        let button = UIButton(configuration: configuration)
        button.changesSelectionAsPrimaryAction = false
        button.showsMenuAsPrimaryAction = true
        
        return button
    }()
    
    private lazy var calendarButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: Const.Image.calendar)
        configuration.baseForegroundColor = .label
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(calendarButtonDidTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var currentWeekTitleButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.titleLabel?.font = .boldSystemFont(ofSize: 35)
        button.tintColor = .label
        button.setImage(UIImage(systemName: Const.Image.chevronDown), for: .normal)
        button.setTitle("WEEK 1 ", for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.changesSelectionAsPrimaryAction = false
        button.showsMenuAsPrimaryAction = true
    
        return button
    }()
    
    private let weeklyPlansPhotoCollectionView = HomeImageCollectionView()
    var dataSource: HomeDataSource!
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
        bindViewModel()
        viewModel.viewDidLoad()
        configureViews()
        setConstraints()
        
        // 네비게이션
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: planListButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: calendarButton)
        
       takeSnapshot()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Methods
    
    func bindViewModel() {
            
        viewModel.userPlanList
            .subscribe { [weak self] userPlans in
                guard let self else { return }
                let children = userPlans.map { planQuery in
                    UIAction(title: planQuery.planName) { action in
                        self.viewModel.fetchPlan(planQuery)
                    }
                }
                
                let menu = UIMenu(children: children)
                
                planListButton.menu = menu
            }
            .disposed(by: disposeBag)
        
        viewModel.currentPlan
            .map { $0.targetWeek }
            .subscribe { [weak self] week in
                guard let self else { return }
                let children = (1...week).map { week in
                    UIAction(title: "WEEK \(week) ") { action in
                        self.viewModel.currentWeek.onNext(week)
                    }
                }
                
                currentWeekTitleButton.menu = UIMenu(children: children)
            }
            .disposed(by: disposeBag)
        
        viewModel.currentWeek
            .subscribe { [weak self] week in
                guard let self else { return }
                viewModel.fetchWeeklyPlan(of: week)
            }
            .disposed(by: disposeBag)
    }
    
    func takeSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(["1", "2", "3", "4", "5"] + ["last"], toSection: .main)
        dataSource.apply(snapshot)
    }
}

extension HomeViewController {
    
    // MARK:  Method
    
    @objc private func calendarButtonDidTapped() {
        let vc = UIViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Configure
    
    private func configureViews() {
        view.addSubview(currentWeekTitleButton)
        view.addSubview(weeklyPlansPhotoCollectionView)
    }
    
    private func setAttributes() {
        
    }
    
    private func setConstraints() {
        currentWeekTitleButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        weeklyPlansPhotoCollectionView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(weeklyPlansPhotoCollectionView.snp.width)
        }
    }
    
   private func configureDataSource() {
       
       let cellRegistration = UICollectionView
           .CellRegistration<HomeImageCollectionViewCell, String>
       {
               cell, indexPath, item in

           cell.label.text = item
           cell.contentView.backgroundColor = .green
        
       }
       
       self.dataSource = HomeDataSource(collectionView: weeklyPlansPhotoCollectionView,
                                        cellProvider: {
           collectionView, indexPath, item in
           
           let cell = collectionView
               .dequeueConfiguredReusableCell(using: cellRegistration,
                                              for: indexPath,
                                              item: item)
           return cell
       })
   }
}
