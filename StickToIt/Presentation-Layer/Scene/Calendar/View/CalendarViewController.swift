//
//  CalendarViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/17/23.
//

import UIKit
import RxSwift

final class CalendarViewController: UIViewController {
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DayPlan>
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, DayPlan>
    
    private enum Section: Int, CaseIterable {
        case main = 0
    }
    
    private var dataSource: DataSource?
    private let viewModel: CalendarViewModel
    private let calendar = StickToItCalendar()
    private let collectionView = CalendarCollectionView()
    
    private let input = PublishSubject<CalendarViewModel.Input>()
    private let disposeBag = DisposeBag()
    
    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        viewModel
            .transform(input: input)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { (owner, event) in
                switch event {
                case .configureUI:
                    owner.calendar.delegate = owner
                    owner.configureDataSource()
                    owner.configureViews()
                    owner.setConstraints()
                    
                case .reload:
                    owner.calendar.reloadData()
                    
                case .showPlansMenu(let planQueries):
                    owner.calendar.select(date: .now)
                    owner.checkCurrentPlan(planQueries)
                    
                case .showPlanInfo(let plan):
                    owner.navigationItem.title = plan.name
                    
                case .showCompletedDayPlans(let dayPlans):
                    owner.takeSnapshot(dayPlans: dayPlans)
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input.onNext(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        input.onNext(.viewWillAppear)
    }
    
    deinit {
        print("🔥 ", self)
    }
}
 
extension CalendarViewController {
    
    private func checkCurrentPlan(_ planQueries: [PlanQuery]) {
        if let currentPlanQueryString = UserDefaults.standard.string(forKey: UserDefaultsKey.currentPlan),
           let currentPlanID = UUID(uuidString: currentPlanQueryString) {
            
            input.onNext(.planMenuTapped(currentPlanID))
        } else {
            if let _firstPlanQueryID = planQueries.first?.id {
                input.onNext(.planMenuTapped(_firstPlanQueryID))
            }
        }
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView
            .CellRegistration<CalendarCollectionViewCell, DayPlan>
        { [weak self] cell, indexPath, item in

            guard let _self = self else { return }
            
            cell.dayPlan = item
        
            guard item.imageURL != nil else { return }

            _self.viewModel.loadImage(dayPlanID: item.id) { data in
                if let data {
                    cell.updateImage(data)
                }
            }
        }

        self.dataSource = DataSource(
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
    
    func takeSnapshot(dayPlans: [DayPlan]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(dayPlans, toSection: .main)
        
        dataSource?.apply(snapshot)
    }
}

extension CalendarViewController: ImageCellDelegate {
    func imageDidSelected(_ dayPlan: DayPlan) {
        let vc = DayPlanViewController(
            viewModel: DIContainer.makeDayPlanViewModel(dayPlan: dayPlan)
        ).embedNavigationController()
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension CalendarViewController: StickToItCalendarDelegate {
    
    func calendarView(didSelectAt date: Date) {
        input.onNext(.didSelect(date))
    }
    // 2
    func numberOfEventsFor(date: Date) -> Int {
        viewModel.eventCount(at: date)
    }
    // 3 마지막 한번
    func eventDefaultColorsFor(date: Date) -> [UIColor]? {
        if viewModel.eventCount(at: date) > 0 {
            return [.systemRed]
        } else {
            return nil
        }
    }
}

extension CalendarViewController: BaseViewConfigurable {
    func configureViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubviews([calendar, collectionView])
    }
    
    func setConstraints() {
        calendar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.7)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.horizontalEdges.equalTo(calendar)
        }
    }
}
