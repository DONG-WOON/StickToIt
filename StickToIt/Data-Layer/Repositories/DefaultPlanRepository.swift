//
//  DefaultPlanRepository.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation

final class DefaultPlanRepository {
    
    private let networkService: NetworkService?
    private let databaseManager: PlanDatabaseManager?
    
    init(
        networkService: NetworkService?,
        databaseManager: PlanDatabaseManager?
    ) {
        self.networkService = networkService
        self.databaseManager = databaseManager
    }
}

extension DefaultPlanRepository: PlanRepository {
    
    func fetchAll() -> Result<[Plan], Error> {
        guard let entities = databaseManager?.fetchAll() else { return .failure((NSError(domain: "fetchAll Error", code: 1000))) }
        return .success(entities.map { $0.toDomain() })
    }
    
    func fetch(query: PlanQuery) -> Result<Plan, Error> {
        guard let entity = databaseManager?.fetch(key: query.planID) as? PlanEntity else { return .failure(NSError(domain: "fetch Error", code: 1000)) }
        return .success(entity.toDomain())
    }
    
    func create(model: Plan, completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseManager?.create(model: model, to: PlanEntity.self, onFailure: { error in
            if let error {
                return completion(.failure(error))
            }
            return completion(.success(true))
        })
    }
}
