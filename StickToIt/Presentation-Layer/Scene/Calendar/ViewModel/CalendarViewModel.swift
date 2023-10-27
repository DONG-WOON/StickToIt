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
        case planMenuTapped(PlanQuery?)
        case refresh
        case didSelect(Date?)
    }
    
    enum Output {
        case reload
        case configureUI
        case showPlansMenu([PlanQuery])
        case showPlanInfo(Plan)
        case showDayPlanImage(data: Data?)
    }
    
    private var currentPlanQuery: PlanQuery?
    private var planCompletedDate: [Date]?
    private var currentPlan: Plan?
    private let output = PublishSubject<Output>()
    private let disposeBag = DisposeBag()
    private let planRepository: PlanRepositoryImp
    private let userRepository: UserRepositoryImp
    
    init(
        planRepository: PlanRepositoryImp,
        userRepository: UserRepositoryImp
    ) {
        self.planRepository = planRepository
        self.userRepository = userRepository
    }
    
    func transform(input: PublishSubject<Input>) -> PublishSubject<Output> {
        input
            .subscribe(with: self) { (_self, event) in
                switch event {
             
                case .viewDidLoad:
                    _self.output.onNext(.configureUI)
                case .viewWillAppear, .refresh:
                    _self.fetchPlanQueries()
    
                case .planMenuTapped(let planQuery):
                    _self.fetchPlanInfo(query: planQuery)
                    
                case .didSelect(let date):
                    _self.selectDayPlan(at: date)
                }
            }
            .disposed(by: disposeBag)
        return output.asObserver()
    }
}

extension CalendarViewModel {
    //1
    func eventCount(at date: Date) -> Int {
        return completedPlanNumber(at: date)
    }
    
    //2
    private func fetchPlanInfo(query: PlanQuery?) {
        guard let query else {
            print("Query 없음")
            return
        }
        
        let result = planRepository.fetch(query: query)
        
        switch result {
        case .success(let plan):
            output.onNext(.showPlanInfo(plan))
            currentPlan = plan
            filterCompletedDayPlans(plan.dayPlans)
            selectDayPlan(at: .now)
        
        case .failure(let error):
            print(error)
        }
    }
    
    private func fetchPlanQueries() {
        guard let uuidString = UserDefaults.standard.string(forKey: UserDefaultsKey.userID), let userID = UUID(uuidString: uuidString) else { return }
        
        let result = userRepository.fetch(key: userID)
        
        switch result {
        case .success(let user):
            let planQueries = user.planQueries
            output.onNext(.showPlansMenu(planQueries))
        case .failure(let error):
            print(error)
        }
    }
    
    func selectDayPlan(at date: Date?) {
        if let plan = currentPlan?.dayPlans.filter({ dayPlan in
            let _date = dayPlan.date
            guard let _selectedDate = date else { return false }
            return DateFormatter.convertDate(from: _selectedDate) == DateFormatter.convertDate(from: _date)
        }).first {
            guard plan.imageURL != nil else {
                output.onNext(.showDayPlanImage(data: nil))
                return
            }
            
            loadImage(dayPlanID: plan.id)
        } else {
            output.onNext(.showDayPlanImage(data: nil))
            return
        }
    }
    
    private func loadImage(dayPlanID: UUID) {
        do {
            let data = try planRepository.loadImageFromDocument(fileName: dayPlanID.uuidString)
            output.onNext(.showDayPlanImage(data: data))
        } catch {
            print(error)
        }
    }
    
    //3
    func filterCompletedDayPlans(_ dayPlans: [DayPlan]) {
        let dates = dayPlans
            .filter { $0.isComplete == true }
            .compactMap { $0.date }
        self.planCompletedDate = dates
    }

    private func completedPlanNumber(at date: Date) -> Int {
        
        if let count = planCompletedDate?.filter({
            DateFormatter.getFullDateString(from: $0) == DateFormatter.getFullDateString(from: date)
        }).count, count > 0 {
            return count
        } else {
            return 0
        }
    }
}

