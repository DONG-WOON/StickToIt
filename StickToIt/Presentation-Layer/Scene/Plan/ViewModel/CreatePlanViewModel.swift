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
                content: nil, imageURL: nil, imageContentIsFill: true)
        }
        
        let plan = Plan(_id: UUID(), name: planName, targetNumberOfDays: targetNumberOfDays, startDate: startDate, endDate: endDate.value ?? startDate, executionDaysOfWeekday: executionDaysOfWeekday, dayPlans: dayPlans)
        
        useCase.create(plan) { [weak self] result in
            switch result {
            case .success:
                let planQuery = PlanQuery(planID: plan._id, planName: plan.name)
                
                guard let userIDString = UserDefaults.standard.string(forKey: Const.Key.userID.rawValue), let userID = UUID(uuidString: userIDString) else { return
                }
                
                self?.save(planQuery: planQuery, to: userID) { [weak self] result in
                    switch result {
                    case .success:
                        self?.saveInUserDefaults(planQuery)
                        completion(.success(true))
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
    
    private func saveInUserDefaults(_ planQuery: PlanQuery) {
        @UserDefault(key: .favoritePlans, type: [PlanQuery].self, defaultValue: nil)
        var favoritePlans
        
        if var _favoritePlans = favoritePlans {
            _favoritePlans.insert(planQuery, at: 0)
            favoritePlans = _favoritePlans
        } else {
            var _favoritePlans: [PlanQuery] = []
            _favoritePlans.append(planQuery)
            favoritePlans = _favoritePlans
        }
    }
}
