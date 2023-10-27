//
//  HomeViewController.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

final class HomeViewController: UIViewController {
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DayPlan>
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, DayPlan>
    
    private enum Section: Int, CaseIterable {
        case main = 0
    }
    
    let viewModel: HomeViewModel
    
    private var dataSource: DataSource?
    private let input = PublishSubject<HomeViewModel.Input>()
    private let disposeBag = DisposeBag()
    
    private lazy var createPlanAction = UIAction(
        title: "목표 추가하기",
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
    
    private lazy var planListButton: UIButton = {
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
    
    private lazy var completedDayPlansButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.title = "0"
        configuration.image = UIImage(resource: .checkedCircle)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.assetColor(.accent1))
        
        configuration.imagePadding = 10
        configuration.preferredSymbolConfigurationForImage = .init(scale: .large)
        configuration.baseForegroundColor = .black
        configuration.baseBackgroundColor = .assetColor(.accent4)
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(completedDayPlansButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private var mainView: UIView?
    
    // MARK: View Life Cycle
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input.onNext(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        input.onNext(.viewWillAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        input.onNext(.viewWillDisappear)
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
                    
                case .configureUI:
                    _self.configureViews()
                    
                case .showCreatePlanScene:
                    _self.showCreatePlanScene()
                    
                case .showPlanWeekScene(let plan):
                    _self.showStatics(plan: plan)
                case .showToast(let title, let message):
                    _self.showToast(title: title, message: message)
                    
                case .loadPlanQueries(let planQueries):
                    _self.setPlanListButtonMenu(with: planQueries)
                    
                case .loadPlan(let plan):
                    _self.update(plan: plan)
                    
                case .loadDayPlans(let dayPlans):
                    _self.takeSnapshot(dayPlans: dayPlans)
                    
                case .loadAchievementProgress(let progress):
                    _self.setAchievementProgress(progress)
                    
                case .startAnimation:
                    _self.startAnimation()
                    
                case .stopAnimation:
                    _self.stopAnimation()
                    
                case .showUserInfo(let user):
                    _self.update(user: user)
                    _self.setEmptyView(user: user)
                    
                case .showCompleteDayPlanCount(let count):
                    _self.completedDayPlansButton.configuration?.title = String(count)
                    
                case .userDeleted:
                    _self.reloadAll()
                }
            }
            .disposed(by: disposeBag)
        
        addNotification()
    }
}

extension HomeViewController {
    func showCreatePlanScene() {
        let vc = CreatePlanViewController(viewModel: DIContainer.makeCreatePlanViewModel())
            .embedNavigationController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func showStatics(plan: Plan?) {
        guard let plan else { return }
        let vc = StaticsViewController(viewModel: StaticsViewModel(plan: plan))
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    func showToast(title: String?, message: String) {
        self.view.makeToast(message, duration: 4, position: .center, title: title, image: UIImage(asset: .placeholder))
    }
    
    func update(user: User?) {
        (view as? HomeView)?.update(user: user)
    }
    
    func update(plan: Plan) {
        (view as? HomeView)?.update(plan: plan)
    }
    
    func setPlanListButtonMenu(with planQuery: [PlanQuery]) {
        var actions: [UIMenuElement] = []
        
        let queryActions = planQuery
            .map { query in
                UIAction(
                    title: query.planName
                ) { [weak self] _ in
                    UserDefaults.standard.setValue(query.id.uuidString, forKey: UserDefaultsKey.currentPlan)
                    self?.input.onNext(.fetchPlan(query))
                }
            }
        
        actions.append(contentsOf: queryActions)
        
        let settingMenu = UIMenu(
            options: .displayInline,
            children: [createPlanAction]
        )
        
        actions.append(settingMenu)
        
        planListButton.menu = UIMenu(
            title: "목표 리스트",
            children: actions
        )
    }
    
    func setAchievementProgress(_ progress: Double) {
        (view as? HomeView)?.setProgress(progress)
    }
    
    func setEmptyView(user: User?) {
        guard let userName = user?.name else { return }
        (view as? HomeEmptyView)?.titleLabel.text = "\(userName) 님\n목표가 아직없어요"
    }
    
    func startAnimation() {
        (view as? HomeEmptyView)?.startAnimation()
    }
    
    func stopAnimation() {
        (view as? HomeEmptyView)?.stopAnimation()
    }
    
    func setViewsAndDelegate(_ planIsExist: Bool) {
        if planIsExist {
            let _view = HomeView()
            
            _view.setDelegate(self)
            
            self.view = _view
            
            configureDataSource(of: _view.collectionView)
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: planListButton)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: completedDayPlansButton)
            
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
        
        dataSource?.apply(snapshot)
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(planCreated), name: .planCreated, object: nil)
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
    
    @objc private func planCreated() {
        input.onNext(.planCreated)
    }
    
    @objc private func reloadAll() {
        input.onNext(.reloadAll)
    }
    
    @objc private func reloadPlan() {
        input.onNext(.reloadPlan)
    }
    
    @objc private func completedDayPlansButtonDidTapped() {
        input.onNext(.completedDayPlansButtonDidTapped)
    }
}

extension HomeViewController: CreatePlanButtonDelegate {
    func createPlan() {
        input.onNext(.createPlanButtonDidTapped)
    }
}

extension HomeViewController {
    // MARK: Configure
    
    private func configureViews() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureDataSource(of collectionView: UICollectionView) {
        
        let cellRegistration = UICollectionView
            .CellRegistration<HomeImageCollectionViewCell, DayPlan>
        { [weak self] cell, indexPath, item in
            
            guard let _self = self else { return }
            
            cell.dayPlan = item
            
            guard item.imageURL != nil else { return }
            
            _self.viewModel.loadImage(dayPlanID: item.id) { data in
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
            viewModel: DIContainer.makeDayPlanViewModel(dayPlan: dayPlan)
        ).embedNavigationController()
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension HomeViewController: PlanSettingButtonDelegate {
    func goToPlanSetting() {
        
    }
    
    func deletePlan() {
        let alert = UIAlertController(title: "목표 삭제", message: "확인을 누르면 지금까지 달성하신 목표까지 모두 삭제됩니다. 목표를 삭제하시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
//            self?.input.onNext(.deletePlan)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
}
