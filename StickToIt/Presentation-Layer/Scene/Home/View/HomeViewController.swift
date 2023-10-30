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
        title: StringKey.addPlan.localized(),
        image: UIImage(resource: .plus),
        handler: { [weak self] _ in
            guard let planCount = self?.viewModel.currentPlanCount else { return }
            if planCount < 5 {
                self?.input.onNext(.createPlanButtonDidTapped)
            } else {
                self?.showAlert(message: StringKey.addPlanAlert.localized())
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
        addNotification()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("🔥 ", self)
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
                    
                case .startAnimation:
                    _self.startAnimation()
                    
                case .stopAnimation:
                    _self.stopAnimation()
                    
                case .showUserInfo(let user):
                    guard let user else { return }
                    _self.update(nickname: user.nickname)
                    
                case .showCompleteDayPlanCount(let count):
                    _self.completedDayPlansButton.configuration?.title = String(count)
                    
                case .userDeleted:
                    _self.reloadAll()
                    
                case .alertError(let error):
                    _self.showAlert(message: error?.localizedDescription)
                    
                case .showKeepGoingMessage(title: let title, message: let message):
                    _self.showKeepGoingAlert(title: title, message: message)
                }
            }
            .disposed(by: disposeBag)
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
    
    func update(nickname: String) {
        (view as? HomeView)?.update(nickname: nickname)
        (view as? HomeEmptyView)?.update(nickname: nickname)
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
            title: StringKey.planList.localized(),
            children: actions
        )
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
            configureDataSource(of: _view.collectionView)
            
            self.view = _view
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: planListButton)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: completedDayPlansButton)
            
            self.input.onNext(.reloadAll)
        } else {
            let _view = HomeEmptyView()
            
            _view.delegate = self
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserInfo), name: .updateNickname, object: nil)
    }
    
    func showAlert(message: String?) {
        let alert = UIAlertController(title: StringKey.noti.localized(), message: message ?? "알 수 없는 오류가 발생했습니다." , preferredStyle: .alert)
        let okAction = UIAlertAction(title: StringKey.done.localized(), style: .default)
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true)
    }
    
    func showKeepGoingAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: StringKey.add100Days.localized(), style: .default) { [weak self] _ in
            self?.input.onNext(.add100DayPlansOfPlan)
        }
        let cancelAction = UIAlertAction(title: StringKey.close.localized(), style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
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
    
    @objc private func updateUserInfo(_ notification: Notification) {
        guard let nickname = notification.userInfo?[NotificationKey.nickname] as? String else { return }
        update(nickname: nickname)
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
            cell.dayPlan = item
            
            guard item.imageURL != nil else { return }
            
            self?.viewModel.loadImage(dayPlanID: item.id) { data in
                cell.update(imageData: data)
            }
        }
        
        dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, item in
                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: item
                )
                guard let _self = self else { return UICollectionViewCell() }
                cell.delegate = _self
                
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

extension HomeViewController: PlanInfoViewDelegate {
    func trashButtonDidTapped() {
        let alert = UIAlertController(title: StringKey.deletePlan.localized(), message: StringKey.deletePlanMessage.localized(), preferredStyle: .alert)
        let okAction = UIAlertAction(title: StringKey.delete.localized(), style: .destructive) { [weak self] _ in
            self?.input.onNext(.deletePlan)
        }
        let cancelAction = UIAlertAction(title: StringKey.cancel.localized(), style: .cancel)

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true)
    }
}
