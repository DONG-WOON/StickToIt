//
//  CalendarViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/17/23.
//

import Foundation
import RxCocoa
import RxSwift


final class CalendarViewModel {
    
    enum Input {
        case viewWillAppear
        case viewDidLoad
        case fetchCurrentDatePlan(Date)
        case planMenuTapped(PlanQuery?)
        case refresh
        case didSelect(Date?)
    }
    
    enum Output {
        case reload
        case showPlansMenu([PlanQuery])
        case showPlanInfo(Plan)
    }
    
    private var currentPlanQuery: PlanQuery?
    private var planCompletedDate: [Date]?
    private let currentMonthPlans = [DayPlan]()
    private let output = PublishSubject<Output>()
    private let disposeBag = DisposeBag()
    private let planRepository: PlanRepositoryImpl
    private let userRepository: UserRepositoryImpl
    
    init(planRepository: PlanRepositoryImpl, userRepository: UserRepositoryImpl) {
        self.planRepository = planRepository
        self.userRepository = userRepository
    }
    
    func transform(input: PublishSubject<Input>) -> PublishSubject<Output> {
        input
            .subscribe(with: self) { (_self, event) in
                switch event {
                case .fetchCurrentDatePlan(let date):
                    _self.fetchCurrentMonthPlan(date: date)
                case .viewDidLoad:
                    _self.fetchPlanQueries()
                case .viewWillAppear, .refresh:
                    _self.fetchPlanQueries()
                    return
                case .planMenuTapped(let planQuery):
                    _self.fetchPlanInfo(query: planQuery)
                case .didSelect(let date):
                    return
                }
            }
            .disposed(by: disposeBag)
        return output.asObserver()
    }
}

extension CalendarViewModel {
    
    func eventCount(at date: Date) -> Int {
        return completedPlanNumber(at: date)
    }
    
    private func fetchCurrentMonthPlan(date: Date) {
        print(date)
    }
    
    private func fetchPlanInfo(query: PlanQuery?) {
        guard let query else {
            print("Query 없음")
            return
        }
        
        let result = planRepository.fetch(query: query)
        
        switch result {
        case .success(let plan):
            output.onNext(.showPlanInfo(plan))
            filterCompletedDayPlans(plan.dayPlans)
        case .failure(let error):
            print(error)
        }
    }
    
    private func fetchPlanQueries() {
        guard let uuidString = UserDefaults.standard.string(forKey: Const.Key.userID.rawValue), let userID = UUID(uuidString: uuidString) else { return }
        
        let result = userRepository.fetch(key: userID)
        
        switch result {
        case .success(let user):
            let planQueries = user.planQueries
            output.onNext(.showPlansMenu(planQueries))
        case .failure(let error):
            print(error)
        }
    }
    
    func filterCompletedDayPlans(_ dayPlans: [DayPlan]) {
        let dates = dayPlans
            .filter { $0.isComplete == true }
            .compactMap { $0.date }
        self.planCompletedDate = dates
        output.onNext(.reload)
    }

    private func completedPlanNumber(at date: Date) -> Int {
        
        if let count = planCompletedDate?.filter({ $0 == date }).count, count > 0 {
            return count
        } else {
            return 0
        }
    }
}

