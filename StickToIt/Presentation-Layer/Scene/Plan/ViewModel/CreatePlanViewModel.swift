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
            executionDaysOfWeekday
        )
        .debug()
        .map { $0.count > 0 && $1.count != 0 }
        .subscribe(with: self, onNext: { (self, isValied) in
            self.planIsValidated.accept(isValied)
        }).disposed(by: disposeBag)
    }
    
    // MARK: Methods
    func createPlan(completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let planName = planName.value
        let executionDaysOfWeekday = executionDaysOfWeekday.value


        let datesFromStartDateToEndDate = Array(0...targetNumberOfDays).map { Calendar.current.date(byAdding: .day, value: $0, to: startDate)!
        }
        
        
        
        let filteredDates = datesFromStartDateToEndDate.filter { date in
            executionDaysOfWeekday.contains {
                $0.rawValue == Calendar.current.dateComponents([.weekday], from: date).weekday!
            }
        }
        
        let timeRemovedDates = filteredDates.map {
            DateFormatter.convertDate(from: $0)
        }
  
        let dayPlans = timeRemovedDates.map { date in
            DayPlan(
                _id: UUID(), isRequired: true,
                isComplete: false, date: date,
                week: Calendar.current.dateComponents([.weekOfYear], from: startDate, to: date!).weekOfYear! + 1,
                content: nil, imageURL: nil)
        }
        
        let userPlan = Plan(_id: UUID(), name: planName, targetNumberOfDays: targetNumberOfDays, startDate: startDate, endDate: endDate.value ?? startDate, executionDaysOfWeekday: executionDaysOfWeekday, dayPlans: dayPlans)
        useCase.create(userPlan, completion: completion)
    }
}
