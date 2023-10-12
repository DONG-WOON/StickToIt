//
//  CreateDayPlanViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/11/23.
//

import Foundation
import RxCocoa

final class CreateDayPlanViewModel<PlanUseCase: CreateDayPlanUseCase>
where PlanUseCase.Model == DayPlan, PlanUseCase.Entity == DayPlanEntity
{
    // MARK: Properties
    private let useCase: PlanUseCase
    private let mainQueue: DispatchQueue
    
    var dayPlan: DayPlan
    var isValidated = BehaviorRelay(value: false)
    
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
        useCase.save(entity: DayPlanEntity.self, matchingWith: dayPlan, completion: completion)
    }
    
    func save(imageData: Data?) {
        useCase.save(dayPlanID: dayPlan._id, imageData: imageData)
    }
    
    func loadImage(completion: @escaping (Data?) -> Void) {
        useCase.loadImage(dayPlanID: dayPlan._id) { data in
            completion(data)
        }
    }
}
