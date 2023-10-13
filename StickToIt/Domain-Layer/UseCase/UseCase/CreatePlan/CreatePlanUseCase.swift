//
//  CreatePlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import Foundation

protocol CreatePlanUseCase: CreateService {
    
}

final class CreatePlanUseCaseImpl<
    Repository: PlanRepository<Plan, PlanEntity, PlanQuery>
>: CreatePlanUseCase {
    
    typealias Repository = Repository
    typealias Model = Plan
    
    // MARK: Properties
    let repository: Repository
    
    // MARK: Life Cycle
    init(repository: Repository) {
        self.repository = repository
    }
    
    func create(_ model: Model, completion: @Sendable @escaping (Result<Bool, Error>) -> Void) {
        repository.create(model: model, completion: completion)
    }
}
