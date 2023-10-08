//
//  CreatePlanViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/3/23.
//

import Foundation
import RxSwift
import RxCocoa

final class CreatePlanViewModel<UseCase: CreatePlanUseCase>
where UseCase.Model == Plan
{
    // MARK: Properties
    private let useCase: UseCase
    private let mainQueue: DispatchQueue
    
    // MARK: Properties
    var planName = BehaviorRelay<String>(value: "")
    var targetPeriod = BehaviorRelay<Int>(value: 3)
    private var startDate: Date = Date()
    private var endDate: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date.now)!
    var executionDaysOfWeek = BehaviorSubject<Set<Week>>(value: [.monday, .tuesday, .wednesday, .thursday, .friday])
    var planIsValidated = BehaviorRelay(value: false)
    private let disposeBag = DisposeBag()
    
    // MARK: Life Cycle
    init(
        useCase: UseCase,
        mainQueue: DispatchQueue = .main
    ) {
        self.useCase = useCase
        self.mainQueue = mainQueue
        
        _ = Observable.combineLatest(
            planName.map { $0.count > 0 },
            executionDaysOfWeek.map { $0.count != 0 }
        ).subscribe(with: self, onNext: { (self, data) in self.planIsValidated.accept(data.0 && data.1)
        }).disposed(by: disposeBag)
    }
    
    // MARK: Methods
    func createPlan() {
        
        let planName = planName.value
        let targetPeriod = targetPeriod.value
        let executionDaysOfWeek = try! executionDaysOfWeek.value()
        
        var userPlan = Plan(_id: UUID(), name: planName, targetPeriod: targetPeriod, startDate: startDate, executionDaysOfWeek: executionDaysOfWeek, weeklyPlans: [])

        useCase.create(userPlan)
    }
    
    func planNameTextNumberValidate() {
        
    }
}
