//
//  DeletePlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/27/23.
//

import Foundation
import RealmSwift

protocol DeletePlanUseCase<Model, Entity> {
    associatedtype Model
    associatedtype Entity
    
    func delete(
        entity: Entity.Type,
        key: UUID,
        onComplete: @escaping @Sendable (Error?) -> Void
    )
    
    func delete(
        entity: Entity.Type,
        key: UUID,
        deleteHandler: @escaping (Realm, Entity) -> Void,
        onComplete: @escaping @Sendable (Error?) -> Void
    )
}

final class DeletePlanUseCaseImp: DeletePlanUseCase {

    typealias Model = Plan
    typealias Entity = PlanEntity
    
    // MARK: Properties
    let repository: (any PlanRepository<Model, Entity>)
    
    // MARK: Life Cycle
    init(repository: some PlanRepository<Model, Entity>) {
        self.repository = repository
    }
    
    
    func delete(
        entity: PlanEntity.Type,
        key: UUID,
        onComplete: @escaping @Sendable (Error?) -> Void
    ) {
        repository.delete(
            entity: entity,
            key: key,
            onComplete: onComplete
        )
    }
    
    func delete(
        entity: PlanEntity.Type,
        key: UUID,
        deleteHandler: @escaping (Realm, PlanEntity) -> Void,
        onComplete: @escaping @Sendable (Error?) -> Void
    ) {
        repository.delete(
            entity: entity,
            key: key,
            deleteHandler: deleteHandler,
            onComplete: onComplete
        )
    }
}
