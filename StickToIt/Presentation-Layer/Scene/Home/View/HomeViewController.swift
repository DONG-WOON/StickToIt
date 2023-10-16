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
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DayPlan>
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, DayPlan>
    
    private enum Section: Int, CaseIterable {
        case main = 0
    }
    
    let viewModel = HomeViewModel(
        useCase: FetchPlanUseCaseImpl(
            repository: PlanRepositoryImpl(
                networkService: nil,
                databaseManager: PlanDatabaseManager()
            )
        )
    )
    
    private var dataSource: DataSource!
    private let disposeBag = DisposeBag()
    
    private lazy var createPlanAction = UIAction(
        title: "계획 추가하기",
        image: UIImage(resource: .plus),
        handler: { [weak self] _ in
            let vc = CreatePlanViewController()
            vc.delegate = self
            
            let nav = vc.embedNavigationController()
            nav.modalPresentationStyle = .fullScreen
            
            self?.present(nav, animated: true)
        }
    )
    
    private lazy var settingAction = UIAction(
        title: "내 계획 설정하기",
        image: UIImage(resource: .gear),
        handler: { [weak self] _ in
            let vc = UIViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    )

    // MARK: UI Properties
    
    private lazy var planTitleButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 7
        configuration.image = UIImage(resource: .listBullet)
        configuration.preferredSymbolConfigurationForImage = .init(scale: .medium)
        configuration.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 0)
        configuration.titleAlignment = .leading
        configuration.baseForegroundColor = .label
        
        let bottomMenu = UIMenu(
            options: .displayInline,
            children: [createPlanAction, settingAction]
        )
        
        let button = UIButton(configuration: configuration)
        button.menu = UIMenu(children: [bottomMenu])
        button.changesSelectionAsPrimaryAction = false
        button.showsMenuAsPrimaryAction = true
        
        return button
    }()
    
    private lazy var calendarButton = ResizableButton(
        image: UIImage(resource: .calendar),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label,
        backgroundColor: .clear,
        target: self,
        action: #selector(calendarButtonDidTapped)
    )
    
    private lazy var currentWeekTitleButton = ResizableButton(
        title: "WEEK 1",
        image: UIImage(resource: .chevronRight),
        symbolConfiguration: .init(scale: .large),
        font: .boldSystemFont(ofSize: 30),
        tintColor: .label, backgroundColor: .clear,
        imageAlignment: .forceRightToLeft,
        target: self,
        action: #selector(currentWeekTitleButtonDidTapped)
    )
    
    private lazy var addDayPlanButton: ResizableButton = {
        let button = ResizableButton(
            image: UIImage(resource: .plus),
            symbolConfiguration: .init(scale: .large),
            tintColor: .white,
            backgroundColor: .systemIndigo.withAlphaComponent(0.6),
            target: self,
            action: #selector(addDayPlanButtonDidTapped)
        )
        return button
    }()

    private lazy var homeAchievementView = AchievementView()
    
//    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let collectionView = HomeImageCollectionView()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
        bindViewModel()
        viewModel.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .reload, object: nil)
        
        configureViews()
        setAttributes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        addDayPlanButton.rounded(cornerRadius: addDayPlanButton.bounds.height / 2)
//
        setConstraints()
        
        addDayPlanButton.rounded(cornerRadius: addDayPlanButton.bounds.height / 2)
    }
    
    // MARK: Methods
    
    
    func bindViewModel() {
    
        viewModel.userPlanList
            .subscribe(with: self) { (_self, userPlanQueries) in
                var actions: [UIMenuElement] = []
    
                let queryActions = userPlanQueries
                    .prefix(2)
                    .map { query in
                        UIAction(
                            title: query.planName
                        ) { _ in
                            _self.title = query.planName
                            _self.viewModel.fetchPlan(query)
                        }
                    }
                        
                actions.append(contentsOf: queryActions)
                
                #warning("나중에 userdefaults에서 불러오기")
                guard let firstPlanQuery = userPlanQueries.first else { return }
                
                _self.title = firstPlanQuery.planName
                _self.viewModel.fetchPlan(firstPlanQuery)
                
                let bottomMenu = UIMenu(
                    options: .displayInline,
                    children: [_self.createPlanAction, _self.settingAction]
                )
                actions.append(bottomMenu)
                
                _self.planTitleButton.menu = UIMenu(children: actions)
            }
            .disposed(by: disposeBag)
        
        viewModel.currentPlan
            .subscribe(with: self) { (_self, plan) in
                _self.viewModel.currentWeek.accept(plan.currentWeek)
                _self.currentWeekTitleButton.setTitle("WEEK \(plan.currentWeek)", for: .normal)
            }
            .disposed(by: disposeBag)
        
        viewModel.currentWeek
            .subscribe(with: self) { (_self, week) in
                _self.viewModel.fetchWeeklyPlan(of: week)
            }
            .disposed(by: disposeBag)
        
        viewModel.currentDayPlans
            .subscribe(with: self) { (_self, dayPlans) in
                
                let requiredDayPlanCount = dayPlans
                    .filter { $0.isRequired }.count
                let completeDayPlanCount = dayPlans
                    .filter { $0.isComplete }.count
                if requiredDayPlanCount != 0 {
                    _self.homeAchievementView.setProgress(Double(completeDayPlanCount) / Double(requiredDayPlanCount))
                }
                _self.takeSnapshot(dayPlans: dayPlans)
                
            }
            .disposed(by: disposeBag)
    }
    
    func takeSnapshot(dayPlans: [DayPlan]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(dayPlans, toSection: .main)
        dataSource.apply(snapshot)
    }
}

// MARK: - @objc Method

extension HomeViewController {
    
    @objc private func reload() {
        self.viewModel.reload()
    }
    
    @objc private func addDayPlanButtonDidTapped() {
//        let vc = PlanWeekSelectViewController(week: viewModel.currentPlanData?.totalWeek ?? 1, currentWeek: viewModel.currentWeek.value)
//        vc.delegate = self
//        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func calendarButtonDidTapped() {
//        let vc = PlanWeekSelectViewController(week: viewModel.currentPlanData?.totalWeek ?? 1, currentWeek: viewModel.currentWeek.value)
//        vc.delegate = self
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func currentWeekTitleButtonDidTapped() {
        let vc = PlanWeekSelectViewController(currentWeek: viewModel.currentWeek.value)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: CreatePlanCompletedDelegate {
    func createPlanCompleted() {
        self.viewModel.reload()
    }
}

extension HomeViewController: PlanWeekSelectDelegate {
    func planWeekSelected(week: Int) {
        self.viewModel.currentWeek.accept(week)
    }
}

extension HomeViewController {
    // MARK: Configure
    
    private func configureViews() {
        self.view.setGradient(
            color1: .init(red: 95/255, green: 193/255, blue: 220/255, alpha: 1).withAlphaComponent(0.5),
            color2: .systemIndigo.withAlphaComponent(0.5),
            startPoint: .init(x: 1, y: 0),
            endPoint: .init(x: 1, y: 1)
        )
        
        view.addSubview(currentWeekTitleButton)
        view.addSubview(collectionView)
        view.addSubview(addDayPlanButton)
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
            make.height.equalTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.1)
        }
        collectionView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.5)
        }
        addDayPlanButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(collectionView.snp.top).offset(-10)
            make.height.width.equalTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.05)
        }
//        activityIndicator.snp.makeConstraints { make in
//            make.center.equalTo(view)
//        }
        homeAchievementView.snp.makeConstraints { make in
            make.top.equalTo(currentWeekTitleButton.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.3)
        }
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView
            .CellRegistration<HomeImageCollectionViewCell, DayPlan>
        { [weak self] cell, indexPath, item in
            
            guard let _self = self else { return }
            
            cell.dayPlan = item
            
            _self.viewModel.loadImage(dayPlanID: item._id) { data in
                cell.update(imageData: data)
            }
        }
        
        self.dataSource = DataSource(
            collectionView: collectionView,
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
    
    func imageDidSelected(_ dayPlan: DayPlan) {
        
        let vc = DayPlanViewController(
            dayPlan: dayPlan
            ).embedNavigationController()
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}
