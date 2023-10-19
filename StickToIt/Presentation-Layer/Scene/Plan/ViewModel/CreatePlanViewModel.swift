//
//  CreatePlanViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/3/23.
//

import Foundation
import RxSwift
import RxCocoa

final class CreatePlanViewModel<PlanUseCase: CreatePlanUseCase>
where PlanUseCase.Model == Plan
{
    // MARK: Properties
    private let useCase: PlanUseCase
    private let mainQueue: DispatchQueue
    
    // MARK: Properties
    
    var planName = BehaviorRelay<String>(value: "")
    var targetNumberOfDays: Int = 3
    var startDate: Date = Date.now
    var endDate: BehaviorRelay<Date?> = BehaviorRelay(value: nil)
    var executionDaysOfWeekday = BehaviorRelay<Set<Week>>(value: [])
    var planIsValidated = BehaviorRelay(value: false)
    private let disposeBag = DisposeBag()
    
    // MARK: Life Cycle
    init(
        useCase: PlanUseCase,
        mainQueue: DispatchQueue = .main
    ) {
        self.useCase = useCase
        self.mainQueue = mainQueue
        
        _ = Observable.combineLatest(
            planName,
            endDate
        )
        .debug()
        .map { $0.count > 0 && ($1 != nil) }
        .subscribe(with: self, onNext: { (self, isValied) in
            self.planIsValidated.accept(isValied)
        }).disposed(by: disposeBag)
    }
    
    // MARK: Methods
    func createPlan(completion: @escaping (Result<PlanQuery, Error>) -> Void) {
        
        let planName = planName.value
//        let executionDaysOfWeekday = executionDaysOfWeekday.value

//        let datesFromStartDateToEndDate = Array(0...targetNumberOfDays).map { Calendar.current.date(byAdding: .day, value: $0, to: startDate)!
//        }
        
//        let filteredDates = datesFromStartDateToEndDate.filter { date in
//            executionDaysOfWeekday.contains {
//                $0.rawValue == Calendar.current.dateComponents([.weekday], from: date).weekday!
//            }
//        }
        let initialDayPlanDates = Array(0...2).map {
            Calendar.current.date(byAdding: .day, value: $0, to: startDate)!
        }
  
        let dayPlans = initialDayPlanDates.map { date in
            DayPlan(
                _id: UUID(), isRequired: true,
                isComplete: false, date: date,
                week: Calendar.current.dateComponents([.weekOfYear], from: startDate, to: date).weekOfYear! + 1,
                content: nil, imageURL: nil, imageContentIsFill: true)
        }
        
        let plan = Plan(_id: UUID(), name: planName, targetNumberOfDays: targetNumberOfDays, startDate: startDate, endDate: endDate.value ?? startDate, executionDaysOfWeekday: [], dayPlans: dayPlans)
        
        useCase.create(plan) { [weak self] result in
            switch result {
            case .success:
                let planQuery = PlanQuery(planID: plan._id, planName: plan.name)
                
                guard let userIDString = UserDefaults.standard.string(forKey: Const.Key.userID.rawValue), let userID = UUID(uuidString: userIDString) else { return
                }
                
                self?.save(planQuery: planQuery, to: userID) { result in
                    switch result {
                    case .success:
                        UserDefaults.standard.setValue(planQuery.planID.uuidString, forKey: Const.Key.currentPlan.rawValue)
                        
                        completion(.success(planQuery))
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func save(planQuery: PlanQuery, to user: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        useCase.save(planQuery: planQuery, to: user, completion: completion)
    }
}
