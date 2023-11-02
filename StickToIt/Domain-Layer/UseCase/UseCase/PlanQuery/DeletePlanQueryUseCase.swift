//
//  DeletePlanQueryUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/29/23.
//

import Foundation
import RealmSwift

final class DeletePlanQueryUseCaseImp: DeletePlanUseCase {

    typealias Model = PlanQuery
    typealias Entity = PlanQueryEntity
    
    // MARK: Properties
    let repository: (any PlanRepository<Model, Entity>)
    
    // MARK: Life Cycle
    init(repository: some PlanRepository<Model, Entity>) {
        self.repository = repository
    }
    
    func delete(
        entity: Entity.Type,
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
        entity: Entity.Type,
        key: UUID,
        deleteHandler: @escaping (Realm, Entity?) -> Void,
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
