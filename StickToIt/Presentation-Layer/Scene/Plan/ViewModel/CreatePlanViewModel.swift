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
    var targetNumberOfDays = BehaviorRelay<Int>(value: 3)
    var startDate: Date = Date()
    var endDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date.now)!
    var executionDaysOfWeekday = BehaviorRelay<Set<Week>>(value: [.monday, .tuesday, .wednesday, .thursday, .friday])
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
            executionDaysOfWeekday
        )
        .map { $0.count > 0 && $1.count != 0 }
        .subscribe(with: self, onNext: { (self, isValied) in self.planIsValidated.accept(isValied)
        }).disposed(by: disposeBag)
    }
    
    // MARK: Methods
    func createPlan(completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let planName = planName.value
        let targetNumberOfDays = targetNumberOfDays.value
        let executionDaysOfWeekday = executionDaysOfWeekday.value
    
        let sevenDaysFromStartDate: [Date] = Array(1...6).map {
            Calendar.current.date(byAdding: .day, value: $0, to: startDate)!
        }
        
        let executionDaysIntValue = executionDaysOfWeekday.map { $0.rawValue }
        
        let requiredDays = sevenDaysFromStartDate.filter { date in
            executionDaysIntValue.contains(where: { $0 == Calendar.current.dateComponents([.weekday], from: date).weekday! }
            )
        }
        
        
        let dayPlans = requiredDays.map { date in
            DayPlan(
                _id: UUID(), isRequired: true,
                isComplete: false, date: date,
                week: 1, content: nil)
        }
        
        let userPlan = Plan(_id: UUID(), name: planName, targetNumberOfDays: targetNumberOfDays, startDate: startDate, endDate: endDate, executionDaysOfWeekday: executionDaysOfWeekday, dayPlans: dayPlans)
        useCase.create(userPlan, completion: completion)
    }
}
