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
        userInfoUseCase: FetchUserInfoUseCaseImpl(
            repository: UserRepositoryImpl(
                networkService: nil,
                databaseManager: UserDatabaseManager()
            )
        ),
        planUseCase: FetchPlanUseCaseImpl(
            repository: PlanRepositoryImpl(
                networkService: nil,
                databaseManager: PlanDatabaseManager()
            )
        )
    )
    
    private var dataSource: DataSource!
    private let input = PublishSubject<HomeViewModel<FetchPlanUseCaseImpl<PlanRepositoryImpl>>.Input>()
    private let disposeBag = DisposeBag()
    
    private lazy var createPlanAction = UIAction(
        title: "계획 추가하기",
        image: UIImage(resource: .plus),
        handler: { [weak self] _ in
            guard let planCount = self?.viewModel.currentPlanCount else { return }
            if planCount < 5 {
                self?.input.onNext(.createPlanButtonDidTapped)
            } else {
                self?.showAlert(message: "계획은 최대 5개까지만 추가할 수 있습니다.")
            }
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
            children: [createPlanAction]
        )
        
        let button = UIButton(configuration: configuration)
        button.menu = UIMenu(children: [bottomMenu])
        button.changesSelectionAsPrimaryAction = false
        button.showsMenuAsPrimaryAction = true
        
        return button
    }()
    
    private lazy var weekButton = ResizableButton(
        title: "1 주차",
        symbolConfiguration: .init(scale: .large),
        tintColor: .label,
        backgroundColor: .clear,
        target: self,
        action: #selector(weekButtonDidTapped)
    )
    
    private var mainView: UIView?
    
    // MARK: View Life Cycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNotification()
        configureViews()
     
        input.onNext(.viewDidLoad)
    }
    
    // MARK: Methods
    
    func bind() {
        viewModel
            .transform(input: input.asObserver())
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { (_self, event) in
                switch event {
                case .setViewsAndDelegate(planIsExist: let isExist):
                    _self.setViewsAndDelegate(isExist)
                    
                case .showCreatePlanScene:
                    _self.showCreatePlanScene()
                    
                case .showPlanWeekScene(let currentWeek):
                    _self.showPlanWeekScene(currentWeek: currentWeek)
                    
                case .loadPlanQueries(let planQueries):
                    _self.makeMenu(with: planQueries)
                    
                case .loadPlan(let plan):
                    _self.setPlanNameLabel(planName: plan.name)
                    
                case .loadDayPlans(let dayPlans):
                    _self.takeSnapshot(dayPlans: dayPlans)
                    
                case .loadAchievementProgress(let progress):
                    _self.setAchievementProgress(progress)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension HomeViewController {
    func showCreatePlanScene() {
        let vc = CreatePlanViewController()
            .embedNavigationController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func showPlanWeekScene(currentWeek: Int) {
        let vc = PlanWeekSelectViewController(currentWeek: currentWeek)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setPlanNameLabel(planName: String) {
        (view as? HomeView)?.setTitleLabel(text: planName)
    }
    
    func makeMenu(with planQuery: [PlanQuery]) {
        var actions: [UIMenuElement] = []

        let queryActions = planQuery
            .map { query in
                UIAction(
                    title: query.planName
                ) { [weak self] _ in
                    UserDefaults.standard.setValue(query.planID.uuidString, forKey: Const.Key.currentPlan.rawValue)
                    self?.navigationItem.title = query.planName
                    self?.input.onNext(.fetchPlan(query))
                }
            }
                
        actions.append(contentsOf: queryActions)
        
        let settingMenu = UIMenu(
            options: .displayInline,
            children: [createPlanAction]
        )
        
        actions.append(settingMenu)
        
        planTitleButton.menu = UIMenu(
            title: "즐겨찾기",
            image: UIImage(systemName: "star.fill"),
            children: actions
        )
    }
    
    func setAchievementProgress(_ progress: Double) {
        (view as? HomeView)?.setProgress(progress)
    }
    
    
    func setViewsAndDelegate(_ planIsExist: Bool) {
        if planIsExist {
            let _view = HomeView()
            configureDataSource(of: _view.collectionView)
            self.view = _view
            self.input.onNext(.reloadAll)
        } else {
            let _view = HomeEmptyView()
            _view.delegate = self
            self.view = _view
        }
    }
    
    func takeSnapshot(dayPlans: [DayPlan]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(dayPlans, toSection: .main)
        
        dataSource.apply(snapshot)
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAll), name: .reloadAll, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPlan), name: .reloadPlan, object: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true)
    }
}

// MARK: - @objc Method

extension HomeViewController {
    
    @objc private func reloadAll() {
        input.onNext(.viewDidLoad)
    }
    
    @objc private func reloadPlan() {
        input.onNext(.reloadPlan)
    }
    
    @objc private func weekButtonDidTapped() {
        input.onNext(.planWeekButtonDidTapped)
    }
}

extension HomeViewController: CreatePlanButtonDelegate {
    func tapButton() {
        input.onNext(.createPlanButtonDidTapped)
    }
}

extension HomeViewController: PlanWeekSelectDelegate {
    func planWeekSelected(week: Int) {
        #warning("sdfsdfsdfsdf")
    }
}

extension HomeViewController {
    // MARK: Configure
    
    private func configureViews() {
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: planTitleButton)
//        if viewModel.currentWeek.value != 1 {
//            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: weekButton)
//        }
    }
    
    private func configureDataSource(of collectionView: UICollectionView) {
        
        let cellRegistration = UICollectionView
            .CellRegistration<HomeImageCollectionViewCell, DayPlan>
        { [weak self] cell, indexPath, item in
            
            guard let _self = self else { return }
            
            cell.dayPlan = item
            
            guard item.imageURL != nil else { return }
            
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
