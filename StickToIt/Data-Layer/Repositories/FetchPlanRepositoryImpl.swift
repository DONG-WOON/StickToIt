//
//  FetchPlanRepositoryImpl.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation

struct FetchPlanRepositoryImpl {
    
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

extension FetchPlanRepositoryImpl: FetchPlanRepository {
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
}
