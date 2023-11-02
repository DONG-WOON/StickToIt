//
//  StaticsViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/23/23.
//

import Foundation
import RxSwift

final class StaticsViewModel {
    
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case configureUI
        case showProgress(Double)
    }
    
    private let output = PublishSubject<Output>()
    
    private let disposeBag = DisposeBag()
    var plan: Plan
    private var completedDayPlans: [DayPlan] {
        return plan.dayPlans.filter { $0.isComplete == true }
    }
    
    init(plan: Plan) {
        self.plan = plan
    }
    
    func transform(input: PublishSubject<Input>) -> PublishSubject<Output> {
        input
            .observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .subscribe(with: self) { owner, event in
                switch event {
                case .viewDidLoad:
                    owner.output.onNext(.configureUI)
                    owner.output.onNext(.showProgress(owner.percentageOfCompleteDays()))
                }
            }
            .disposed(by: disposeBag)
        
        return output.asObserver()
    }
}
extension StaticsViewModel {
    
    func percentageOfCompleteDays() -> Double {
        
        let numberOfCompletedDayPlans = self.completedDayPlans.count
        let totalNumberOfDayPlans = self.plan.dayPlans.count
        
        return Double(numberOfCompletedDayPlans) / Double(totalNumberOfDayPlans)
    }
}
