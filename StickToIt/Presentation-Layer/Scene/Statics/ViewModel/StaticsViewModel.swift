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
            .subscribe(with: self) { _self, event in
                switch event {
                case .viewDidLoad:
                    _self.output.onNext(.configureUI)
                    _self.output.onNext(.showProgress(_self.percentageOfCompleteDays()))
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
