//
//  UpdateDayPlanViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/11/23.
//

import Foundation

final class UpdateDayPlanViewModel<PlanUseCase: UpdatePlanUseCase>
where PlanUseCase.Model == DayPlan, PlanUseCase.Entity == DayPlanEntity
{
    // MARK: Properties
    private let useCase: PlanUseCase
    private let mainQueue: DispatchQueue
    
    var dayPlan: DayPlan
    
    init(
        dayPlan: DayPlan,
        useCase: PlanUseCase,
        mainQueue: DispatchQueue = .main
    ) {
        self.dayPlan = dayPlan
        self.useCase = useCase
        self.mainQueue = mainQueue
    }
        
    func viewDidLoad() {
        
    }
    
    func save(completion: @escaping (Result<Bool, Error>) -> Void) {
        useCase.update(entity: DayPlanEntity.self, matchingWith: dayPlan, completion: completion)
    }
}
