//
//  CalendarViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/17/23.
//

import UIKit
import RxSwift

final class CalendarViewController: UIViewController {
    
    private let viewModel: CalendarViewModel
    private let calendar = StickToItCalendar()
    
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
                case .reload:
                    _self.calendar.reloadData()
                case .showPlansMenu(let planQueries):
                    
                    if let currentPlanQueryString = UserDefaults.standard.string(forKey: Const.Key.currentPlan.rawValue), let currentPlanID = UUID(uuidString: currentPlanQueryString) {
                        
                        let currentPlanQuery = PlanQuery(planID: currentPlanID, planName: "")
                        _self.input.onNext(.planMenuTapped(currentPlanQuery))
                    } else {
                        if let _firstPlanQuery = planQueries.first {
                            _self.input.onNext(.planMenuTapped(_firstPlanQuery))
                        }
                    }

                case .showPlanInfo(let plan):
                    _self.title = plan.name
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        calendar.select(date: .now)
        calendar.delegate = self
        
        input.onNext(.viewDidLoad)
        
        configureViews()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        input.onNext(.viewWillAppear)
    }
}

extension CalendarViewController: StickToItCalendarDelegate {
    
    func calendarWillDisplay(date: Date) {
        
    }
    
    func pageDidChange(on date: Date) {
        input.onNext(.fetchCurrentDatePlan(date))
    }
    
    func calendarView(didSelectAt date: Date?) {
        input.onNext(.didSelect(date))
    }
    
    func numberOfEventsFor(date: Date) -> Int {
        viewModel.eventCount(at: date)
    }
    
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
        
        view.addSubview(calendar)
    }
    
    func setConstraints() {
        calendar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.7)
        }
    }
}
