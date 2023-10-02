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
    
    private lazy var planTitleButton: ResizableButton = {
        let button = ResizableButton(
            title: "계획 설정",
            image: UIImage(systemName: Const.Image.chevronDown),
            symbolSize: 15, font: .systemFont(ofSize: 20),
            tintColor: .label,
            imageAlignment: .forceRightToLeft,
            target: self,
            action: #selector(planTitleButtonDidTapped)
        )
        
        button.menu = UIMenu(children:[
            UIAction(
                title: "내 계획 설정하기",
                image: UIImage(systemName: Const.Image.gear),
                handler: { _ in
                    let vc = UIViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            )
        ])
        button.changesSelectionAsPrimaryAction = false
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private lazy var calendarButton = ResizableButton(
        image: UIImage(systemName: Const.Image.calendar),
        symbolSize: 25,
        tintColor: .label,
        target: self,
        action: #selector(calendarButtonDidTapped)
    )
    
    private lazy var currentWeekTitleButton = ResizableButton(
        title: "WEEK 1",
        image: UIImage(systemName: Const.Image.chevronRight),
        symbolSize: 30, font: .boldSystemFont(ofSize: 35),
        tintColor: .label, imageAlignment: .forceRightToLeft,
        target: self,
        action: #selector(currentWeekTitleButtonDidTapped)
    )

    
    
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: planTitleButton)
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
                guard let menu = planTitleButton.menu else { return }
                var menuElements = menu.children
                
                let planActions = userPlans.map { planQuery in
                    UIAction(title: planQuery.planName) { action in
                        self.viewModel.fetchPlan(planQuery)
                    }
                }
                menuElements.insert(contentsOf: planActions, at: 0)
               
                planTitleButton.menu = UIMenu(children: menuElements)
            }
            .disposed(by: disposeBag)
        
        viewModel.currentPlan
            .map { $0.targetWeek }
            .subscribe { [weak self] week in
                guard let self else { return }
                let children = (1...week).map { week in
                    UIAction(title: "WEEK \(week)") { action in
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
// MARK: - @objc Method

extension HomeViewController {
    
    @objc private func planTitleButtonDidTapped() {
        
    }
    
    @objc private func calendarButtonDidTapped() {
        let vc = UIViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func currentWeekTitleButtonDidTapped() {
        let vc = UIViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController {
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
