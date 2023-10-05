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
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    
    private enum Section: Int, CaseIterable {
        case main = 0
        case last
    }
    
    let viewModel = HomeViewModel(
        showPlanUseCase: HomePlanUseCase(
            planRepository: DefaultPlanRepository(
                networkService: nil,
                databaseManager: PlanDatabaseManager(queue: .main)
            )
        )
    )
    private var dataSource: DataSource!
    
    private var disposeBag = DisposeBag()
    
    private lazy var createPlanAction = UIAction(
        title: "계획 추가하기",
        image: UIImage(systemName: Const.Image.plus),
        handler: { _ in
            let vc = CreatePlanViewController()
                .embedNavigationController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    )
    
    private lazy var settingAction = UIAction(
        title: "내 계획 설정하기",
        image: UIImage(systemName: Const.Image.gear),
        handler: { _ in

        }
    )
    
    // MARK: UI Properties
    
    private lazy var planTitleButton: ResizableButton = {
        let button = ResizableButton(
            title: "계획 설정",
            image: UIImage(systemName: Const.Image.chevronDown),
            symbolConfiguration: .init(font: .systemFont(ofSize: 17), scale: .small),
            tintColor: .label,
            imageAlignment: .forceRightToLeft,
            target: self,
            action: #selector(planTitleButtonDidTapped)
        )
        
        let bottomMenu = UIMenu(title: "", options: .displayInline, children: [settingAction])
        button.menu = UIMenu(children:[bottomMenu])
        button.changesSelectionAsPrimaryAction = false
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private lazy var calendarButton = ResizableButton(
        image: UIImage(systemName: Const.Image.calendar),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label,
        target: self,
        action: #selector(calendarButtonDidTapped)
    )
    
    private lazy var currentWeekTitleButton = ResizableButton(
        title: "WEEK 1",
        image: UIImage(systemName: Const.Image.chevronRight),
        symbolConfiguration: .init(scale: .large),
        font: .boldSystemFont(ofSize: 30),
        tintColor: .label, imageAlignment: .forceRightToLeft,
        target: self,
        action: #selector(currentWeekTitleButtonDidTapped)
    )

    private lazy var homeAchievementView = AchievementView()
//    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let weeklyPlansPhotoCollectionView = HomeImageCollectionView()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
        bindViewModel()
        viewModel.viewDidLoad()
        
        configureViews()
        setAttributes()
        
        homeAchievementView.circleView.animate()
        
        takeSnapshot()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.reload()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setConstraints()
    }
    
    // MARK: Methods
    
    func bindViewModel() {
        
        viewModel.userPlanList
            .subscribe(with: self) { (_self, userPlanQueries) in
                var actions: [UIMenuElement] = []
                
                userPlanQueries.forEach { planQuery in
                    actions.append(
                        UIAction(title: planQuery.planName) { _ in
                        _self.viewModel.fetchPlan(planQuery)
                    })
                }
                
                guard let firstPlanQuery = userPlanQueries.first else { return }
                
                _self.viewModel.fetchPlan(firstPlanQuery)
                _self.planTitleButton.setTitle(firstPlanQuery.planName + " ", for: .normal)
                
                let bottomMenu = UIMenu(
                    options: .displayInline,
                    children: [_self.createPlanAction, _self.settingAction]
                )
                actions.append(bottomMenu)
                
                _self.planTitleButton.menu = UIMenu(children: actions)
            }
            .disposed(by: disposeBag)
        
        viewModel.currentPlan
            .map { $0.targetPeriod / 7 < 1 ? 1 : $0.targetPeriod / 7 }
            .subscribe(with: self) { (_self, week) in
                #warning("현재 몇주차인지~")
                _self.currentWeekTitleButton.setTitle("WEEK \(week)", for: .normal)
            }
            .disposed(by: disposeBag)
        
        viewModel.currentWeek
            .subscribe(with: self) { (_self, week) in
                _self.viewModel.fetchWeeklyPlan(of: week)
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
//        view.addSubview(activityIndicator)
        view.addSubview(homeAchievementView)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: planTitleButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: calendarButton)
    }
    
    private func setAttributes() {
//        activityIndicator.isHidden = true

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
//        activityIndicator.snp.makeConstraints { make in
//            make.center.equalTo(view)
//        }
        homeAchievementView.snp.makeConstraints { make in
            make.top.equalTo(currentWeekTitleButton.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(weeklyPlansPhotoCollectionView.snp.top).offset(-20)
        }
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView
            .CellRegistration<HomeImageCollectionViewCell, String>
        { cell, indexPath, item in
        }
        
        self.dataSource = DataSource(
            collectionView: weeklyPlansPhotoCollectionView,
            cellProvider: { collectionView, indexPath, item in
                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: item
                )
                cell.delegate = self
                return cell
            }
        )
    }
}

extension HomeViewController: HomeImageCollectionViewCellDelegate {
    
    func addImageButtonDidTapped() {
        let vc = ImageSelectionViewController(authorization: .authorized)
            .embedNavigationController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func editImageButtonDidTapped() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "편집", style: .default)
        let delete = UIAlertAction(title: "삭제", style: .destructive)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(edit)
        alert.addAction(delete)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
}
