//
//  PlanRepositoryImpl.swift
//  StickToIt
//
//  Created by 서동운 on 10/10/23.
//

import Foundation

struct PlanRepositoryImpl {

    // MARK: Properties
    private let networkService: NetworkService?
    private let databaseManager: PlanDatabaseManager?

    // MARK: Life Cycle
    init(
        networkService: NetworkService?,
        databaseManager: PlanDatabaseManager?
    ) {
        self.networkService = networkService
        self.databaseManager = databaseManager
    }
}

extension PlanRepositoryImpl: PlanRepository {
    typealias Model = Plan
    typealias Entity = PlanEntity
    typealias Query = PlanQuery
    
    func fetchAll() -> Result<[Model], Error> {
        guard let entities = databaseManager?.fetchAll() else { return .failure((NSError(domain: "fetchAll Error", code: 1000))) }
        return .success(entities.map { $0.toDomain() })
    }
    
    func fetch(query: PlanQuery) -> Result<Model, Error> {
        guard let entity = databaseManager?.fetch(key: query.planID) as? PlanEntity else { return .failure(NSError(domain: "fetch Error", code: 1000)) }
        return .success(entity.toDomain())
    }
    
    func create(model: Model, completion: @Sendable @escaping (Result<Bool, Error>) -> Void) {
        databaseManager?.create(model: model, to: PlanEntity.self, onFailure: { error in
            if let error {
                return completion(.failure(error))
            }
            return completion(.success(true))
        })
    }
    
}
