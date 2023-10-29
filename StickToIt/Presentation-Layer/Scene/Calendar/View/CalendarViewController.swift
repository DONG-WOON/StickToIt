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
            .transform(input: input.asObserver())
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { (_self, event) in
                switch event {
                case .configureUI:
                    _self.calendar.delegate = self
                    _self.configureDataSource()
                    _self.configureViews()
                    _self.setConstraints()
                    
                case .reload:
                    _self.calendar.reloadData()
                    
                case .showPlansMenu(let planQueries):
                    _self.calendar.select(date: .now)
                    _self.checkCurrentPlan(planQueries)
                    
                case .showPlanInfo(let plan):
                    _self.navigationItem.title = plan.name
                    
                case .showCompletedDayPlans(let dayPlans):
                    _self.takeSnapshot(dayPlans: dayPlans)
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
}
 
extension CalendarViewController {
    
    private func checkCurrentPlan(_ planQueries: [PlanQuery]) {
        if let currentPlanQueryString = UserDefaults.standard.string(forKey: UserDefaultsKey.currentPlan), let currentPlanID = UUID(uuidString: currentPlanQueryString) {
            
            let currentPlanQuery = PlanQuery(id: currentPlanID, planName: "")
            input.onNext(.planMenuTapped(currentPlanQuery))
        } else {
            if let _firstPlanQuery = planQueries.first {
                input.onNext(.planMenuTapped(_firstPlanQuery))
            }
        }
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView
            .CellRegistration<CalendarCollectionViewCell, DayPlan>
        { [weak self] cell, indexPath, item in
            
            guard let _self = self else { return }
            guard item.imageURL != nil else { return }
            
            _self.viewModel.loadImage(dayPlanID: item.id) { data in
                if let data {
                    cell.updateImage(data)
                }
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

extension CalendarViewController: StickToItCalendarDelegate {
    
    func calendarView(didSelectAt date: Date?) {
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
        
        calendar.layer.borderWidth = 0.5
        calendar.layer.borderColor = UIColor.assetColor(.accent2).cgColor
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
