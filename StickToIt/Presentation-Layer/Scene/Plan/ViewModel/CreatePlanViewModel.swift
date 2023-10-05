//
//  CreatePlanViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/3/23.
//

import Foundation
import RxSwift
import RxCocoa

final class CreatePlanViewModel {
    
    private let createPlanUseCase: PlanUseCase
    private let mainQueue: DispatchQueue
    
    var planName = BehaviorRelay<String>(value: "")
    var targetPeriod = BehaviorRelay<Int>(value: 3)
    
    private var startDate: Date = Date()
    private var endDate: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date.now)!
    var executionDaysOfWeek = BehaviorSubject<Set<Week>>(value: [.monday, .tuesday, .wednesday, .thursday, .friday])
    
    var planIsValidated = BehaviorRelay(value: false)
    
    private var disposeBag = DisposeBag()
    
    init(
        createPlanUseCase: PlanUseCase,
        mainQueue: DispatchQueue = .main
    ) {
        self.createPlanUseCase = createPlanUseCase
        self.mainQueue = mainQueue
        
        _ = Observable.combineLatest(
            planName.map { $0.count > 0 },
            executionDaysOfWeek.map { $0.count != 0 }
        ).subscribe(with: self, onNext: { (self, data) in self.planIsValidated.accept(data.0 && data.1)
        }).disposed(by: disposeBag)
    }
    
    func createPlan() {
        
        let planName = planName.value
        let targetPeriod = targetPeriod.value
        let executionDaysOfWeek = try! executionDaysOfWeek.value()
        
        var userPlan = Plan(_id: UUID(), name: planName, targetPeriod: targetPeriod, startDate: startDate, executionDaysOfWeek: executionDaysOfWeek, weeklyPlans: [])

        createPlanUseCase.createPlan(userPlan)
    }
    
    func planNameTextNumberValidate() {
        
    }
}
