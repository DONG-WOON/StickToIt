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
        case planMenuTapped(UUID)
        case refresh
        case didSelect(Date?)
    }
    
    enum Output {
        case reload
        case configureUI
        case showPlansMenu([PlanQuery])
        case showPlanInfo(Plan)
        case showCompletedDayPlans([DayPlan])
    }
    
    private var currentPlanQuery: PlanQuery?
    private var planCompletedDate: [Date]?
    private var currentPlan: Plan?
    private let output = PublishSubject<Output>()
    private let disposeBag = DisposeBag()
    private let planRepository: any PlanRepository<Plan, PlanEntity>
    private let userRepository: any UserRepository<User, UserEntity>
    
    init(
        planRepository: some PlanRepository<Plan, PlanEntity>,
        userRepository: some UserRepository<User, UserEntity>
    ) {
        self.planRepository = planRepository
        self.userRepository = userRepository
    }
    
    func transform(input: PublishSubject<Input>) -> PublishSubject<Output> {
        input
            .observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .subscribe(with: self) { (owner, event) in
                switch event {
             
                case .viewDidLoad:
                    owner.output.onNext(.configureUI)
                    
                case .viewWillAppear, .refresh:
                    owner.fetchPlanQueries()
    
                case .planMenuTapped(let id):
                    owner.fetchPlanInfo(ofPlanID: id)
                    
                case .didSelect(let date):
                    owner.selectDayPlan(at: date)
                }
            }
            .disposed(by: disposeBag)
        return output
    }
}

extension CalendarViewModel {
    
    func eventCount(at date: Date) -> Int {
        return completedPlanNumber(at: date)
    }
    
    private func fetchPlanQueries() {
        guard let uuidString = UserDefaults.standard.string(forKey: UserDefaultsKey.userID), let userID = UUID(uuidString: uuidString) else { return }
        
        userRepository.fetch(key: userID) { [weak self] result in
            switch result {
            case .success(let user):
                let planQueries = user.planQueries
                self?.output.onNext(.showPlansMenu(planQueries))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchPlanInfo(ofPlanID id: UUID) {
        
        planRepository.fetch(key: id) { [weak self] result in
            switch result {
            case .success(let plan):
                self?.output.onNext(.showPlanInfo(plan))
                self?.currentPlan = plan
                guard let completedDayPlans = self?.filterCompletedDayPlans(plan.dayPlans) else { return }
                self?.planCompletedDate = completedDayPlans.compactMap { $0.date }
                
                let filteredDayPlans = completedDayPlans.filter { Calendar.current.isDate(.now, equalTo: $0.date, toGranularity: .month) }
                
                self?.output.onNext(.showCompletedDayPlans(filteredDayPlans))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func selectDayPlan(at date: Date?) {
        guard let plan = currentPlan, let date else { return }
    
        let completedDayPlans = filterCompletedDayPlans(plan.dayPlans)
        
        let filteredDayPlans = completedDayPlans.filter { Calendar.current.isDate(date, equalTo: $0.date, toGranularity: .month) }
        
        output.onNext(.showCompletedDayPlans(filteredDayPlans))
    }
    
    func loadImage(dayPlanID: UUID, completion: @escaping (Data?) -> Void) {
        do {
            let data = try planRepository.loadImageFromDocument(fileName: dayPlanID.uuidString)
            completion(data)
        } catch {
            print(error)
        }
    }
    
    //3
    func filterCompletedDayPlans(_ dayPlans: [DayPlan]) -> [DayPlan] {
        return dayPlans.filter { $0.isComplete == true }
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

