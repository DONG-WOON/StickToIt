//
//  DefaultPlanRepository.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation

protocol PlanRepository: Repository {
    
    func fetchAll() -> Result<[Plan], Error>
    func fetch(query: PlanQuery) -> Result<Plan, Error>
    func save(model: Plan, completion: @escaping (Result<Bool, Error>) -> Void)
}

final class DefaultPlanRepository {
    
    private let networkService: NetworkService?
    private let databaseManager: (any DatabaseManager)?
    
    init(
        networkService: NetworkService?,
        databaseManager: (some DatabaseManager)?
    ) {
        self.networkService = networkService
        self.databaseManager = databaseManager
    }
}

extension DefaultPlanRepository: PlanRepository {
    
    func fetchAll() -> Result<[Plan], Error> {
        guard let entities = (databaseManager as? PlanDatabaseManager)?.fetchAll() else { return .failure((NSError(domain: "", code: 1000))) }
        return .success(entities.map { $0.toDomain() })
    }
    
    func fetch(query: PlanQuery) -> Result<Plan, Error> {
        guard let entity = (databaseManager as? PlanDatabaseManager)?.fetch(key: query.planID) as? PlanEntity else { return .failure(NSError(domain: "", code: 1000)) }
        return .success(entity.toDomain())
    }
    
    func save(model: Plan, completion: @escaping (Result<Bool, Error>) -> Void) {
        (databaseManager as? PlanDatabaseManager)?.create(model: model, to: PlanEntity.self, onFailure: { error in
            if let error {
                return completion(.failure(error))
            }
            return completion(.success(true))
        })
    }
}
