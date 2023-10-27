//
//  DeletePlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/27/23.
//

import Foundation

protocol DeletePlanUseCase: DeleteService { }

final class DeletePlanUseCaseImp: DeletePlanUseCase {
    
    typealias Query = PlanQuery
    typealias Model = Plan
    typealias Entity = PlanEntity
    
    // MARK: Properties
    let repository: (any PlanRepository<Query, Model, Entity>)
    
    // MARK: Life Cycle
    init(repository: some PlanRepository<Query, Model, Entity>) {
        self.repository = repository
    }
    
    
    func delete(entity: Entity.Type, matchingWith model: Model, completion: @escaping (Result<Void, Error>) -> Void) {
        
//        repository.delete(entity: entity, matchingWith: model) { error in
//            if let error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
    }
}
