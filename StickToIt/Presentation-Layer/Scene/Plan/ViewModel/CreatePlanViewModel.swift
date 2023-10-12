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
    private var startDate: Date = Date()
    var endDate: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date.now)!
    var executionDaysOfWeek = BehaviorRelay<Set<Week>>(value: [.monday, .tuesday, .wednesday, .thursday, .friday])
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
            executionDaysOfWeek
        )
        .map { $0.count > 0 && $1.count != 0 }
        .subscribe(with: self, onNext: { (self, isValied) in self.planIsValidated.accept(isValied)
        }).disposed(by: disposeBag)
    }
    
    // MARK: Methods
    func createPlan(completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let planName = planName.value
        let targetNumberOfDays = targetNumberOfDays.value
        let executionDaysOfWeek = executionDaysOfWeek.value
        
        
//        let minimumRequiredDayOfDayPlans = targetNumberOfDays < 7 ? targetNumberOfDays : 7
//
        
        
        let dayPlans = executionDaysOfWeek.map { day in DayPlan(_id: UUID(), isRequired: true, date: nil, week: 1, executionDaysOfWeek: day, content: nil) }
        
        let userPlan = Plan(_id: UUID(), name: planName, targetNumberOfDays: targetNumberOfDays, startDate: startDate, endDate: endDate, executionDaysOfWeek: executionDaysOfWeek, dayPlans: dayPlans)
        useCase.create(userPlan, completion: completion)
        
    }
    
    func planNameTextNumberValidate() {
        
    }
}
