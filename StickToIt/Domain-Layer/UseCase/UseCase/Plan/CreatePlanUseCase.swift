//
//  CreatePlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import Foundation

protocol CreatePlanUseCase<Model, Entity> {
    associatedtype Model
    associatedtype Entity
    
    func create(
        _ model: Model,
        completion: @Sendable @escaping (Result<Bool, Error>) -> Void
    )
}

final class CreatePlanUseCaseImp: CreatePlanUseCase {
    
    typealias Model = Plan
    typealias Entity = PlanEntity
    
    // MARK: Properties
    let repository: (any PlanRepository<Model, Entity>)
    
    // MARK: Life Cycle
    init(repository: some PlanRepository<Model, Entity>) {
        self.repository = repository
    }
    
    func create(
        _ model: Model,
        completion: @Sendable @escaping (Result<Bool, Error>) -> Void
    ) {
        repository.create(model: model, completion: completion)
    }
}
