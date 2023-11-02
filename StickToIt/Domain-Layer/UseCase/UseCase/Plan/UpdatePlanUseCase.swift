//
//  UpdatePlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/29/23.
//

import Foundation

protocol UpdatePlanUseCase<Model, Entity> {
    
    associatedtype Model
    associatedtype Entity
    
    func update(
        entity: Entity.Type,
        key: UUID,
        updateHandler: @escaping (Entity?) -> Void,
        onComplete: @Sendable @escaping (Error?) -> Void
    )
}

final class UpdatePlanUseCaseImp: UpdatePlanUseCase {
    
    typealias Model = Plan
    typealias Entity = PlanEntity
    
    let repository: (any PlanRepository<Model, Entity>)
    
    init(repository: some PlanRepository<Model, Entity>) {
        self.repository = repository
    }

    func update(
        entity: PlanEntity.Type,
        key: UUID,
        updateHandler: @escaping (PlanEntity?) -> Void,
        onComplete: @Sendable @escaping (Error?) -> Void
    ) {
        repository.update(
            entity: entity,
            key: key,
            updateHandler: updateHandler,
            onComplete: onComplete
        )
    }
}
