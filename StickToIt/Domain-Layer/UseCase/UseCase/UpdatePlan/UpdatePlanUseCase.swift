//
//  UpdatePlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/12/23.
//

import Foundation

protocol UpdatePlanUseCase: UpdateService {
    
}

final class UpdatePlanUseCaseImpl<
    Repository: PlanRepository<DayPlan, DayPlanEntity, PlanQuery>
>: UpdatePlanUseCase {
    
    typealias Repository = Repository
    typealias Model = DayPlan
    typealias Entity = DayPlanEntity
    
    // MARK: Properties
    let repository: Repository
    
    // MARK: Life Cycle
    init(repository: Repository) {
        self.repository = repository
    }
    
    func update(entity: DayPlanEntity.Type, matchingWith model: DayPlan, completion: @Sendable @escaping (Result<Bool, Error>) -> Void) {
        repository.update(entity: entity, matchingWith: model) { error in
            guard let error else {
                return completion(.success(true))
            }
            return completion(.failure(error))
        }
    }
}

