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
    // MARK: Properties
    private let planUseCase: any CreatePlanUseCase<Plan, PlanEntity>
    private let userUseCase: any UpdateUserUseCase<User, UserEntity>
    private let mainQueue: DispatchQueue
    
    // MARK: Properties
    
    var planName = BehaviorSubject(value: "")
    var targetNumberOfDays: Int = 3
    var startDate: Date = Date.now
    var endDate: BehaviorRelay<Date?> = BehaviorRelay(value: nil)
    var planIsValidated = BehaviorRelay(value: false)
    private let disposeBag = DisposeBag()
    
    // MARK: Life Cycle
    init(
        planUseCase: some CreatePlanUseCase<Plan, PlanEntity>,
        userUseCase: some UpdateUserUseCase<User, UserEntity>,
        mainQueue: DispatchQueue = .main
    ) {
        self.planUseCase = planUseCase
        self.userUseCase = userUseCase
        self.mainQueue = mainQueue
        
        _ = Observable.combineLatest(
            planName,
            endDate
        )
        .map { $0.count > 0 && ($1 != nil) }
        .subscribe(with: self, onNext: { (self, isValidated) in
            self.planIsValidated.accept(isValidated)
        }).disposed(by: disposeBag)
    }
    
    // MARK: Methods
    func createPlan(completion: @escaping (Result<PlanQuery, Error>) -> Void) {
        
        guard let planName = try? planName.value() else {
            completion(.failure(NSError(domain: "목표 이름이 없어요.", code:    -1001)))
            return
        }
        
        let startDay = startDate
        guard let endDay = endDate.value else {
            completion(.failure(NSError(domain: "종료일이 설정되지않았어요.", code: -1010)))
            return
        }
        
        let allDays =  Calendar.current.dateComponents(
            [.day],
            from: startDay,
            to: endDay
        ).day!
        
        let initialDayPlanDates = Array(0...allDays + 1).map {
            Calendar.current.date(byAdding: .day, value: $0, to: startDate)!
        }
  
        let dayPlans = initialDayPlanDates.map { date in
            DayPlan(
                id: UUID(), isRequired: true,
                isComplete: false, date: date,
                week: Calendar.current.dateComponents([.weekOfYear], from: startDate, to: date).weekOfYear! + 1,
                content: nil, imageURL: nil)
        }
        
        let plan = Plan(
            id: UUID(), name: planName,
            targetNumberOfDays: targetNumberOfDays,
            startDate: startDate, endDate: endDate.value ?? startDate,
            dayPlans: dayPlans
        )
        
        planUseCase.create(plan) { [weak self] result in
            switch result {
            case .success:
                let planQuery = PlanQuery(id: plan.id, planName: plan.name)
                
                guard let userIDString = UserDefaults.standard.string(forKey: UserDefaultsKey.userID), let userID = UUID(uuidString: userIDString) else {
                    return
                }
                
                self?.save(
                    planQuery: planQuery,
                    to: userID
                ) { result in
                    switch result {
                    case .success:
                        UserDefaults.standard.setValue(
                            planQuery.id.uuidString,
                            forKey: UserDefaultsKey.currentPlan
                        )
                        
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
    
    private func save(
        planQuery: PlanQuery,
        to user: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        userUseCase.update(userID: user) { entity in
            entity.planQueries.append(planQuery.toEntity())
        } onComplete: { error in
            if let error {
                completion(.failure(error))
            }
            completion(.success(()))
        }

    }
}
