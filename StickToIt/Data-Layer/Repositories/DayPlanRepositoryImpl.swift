//
//  DayPlanRepositoryImpl.swift
//  StickToIt
//
//  Created by 서동운 on 10/12/23.
//

import Foundation

struct DayPlanRepositoryImpl {

    // MARK: Properties
    private let networkService: NetworkService?
    private let databaseManager: DayPlanDataBaseManager?

    // MARK: Life Cycle
    init(
        networkService: NetworkService?,
        databaseManager: DayPlanDataBaseManager?
    ) {
        self.networkService = networkService
        self.databaseManager = databaseManager
    }
}

extension DayPlanRepositoryImpl: PlanRepository {
   
    typealias Model = DayPlan
    typealias Entity = DayPlanEntity
    typealias Query = PlanQuery
    
    func fetchAll() -> Result<[Model], Error> {
        guard let entities = databaseManager?.fetchAll() else { return .failure((NSError(domain: "fetchAll Error", code: 1000))) }
        return .success(entities.map { $0.toDomain() })
    }
    
    func fetch(query: PlanQuery) -> Result<Model, Error> {
        guard let entity = databaseManager?.fetch(key: query.planID) as? DayPlanEntity else { return .failure(NSError(domain: "fetch Error", code: 1000)) }
        return .success(entity.toDomain())
    }
    
    func create(model: Model, completion: @Sendable @escaping (Result<Bool, Error>) -> Void) {
        databaseManager?.create(model: model, to: DayPlanEntity.self, onFailure: { error in
            if let error {
                return completion(.failure(error))
            }
            return completion(.success(true))
        })
    }
    
    func update(entity: DayPlanEntity.Type, matchingWith model: DayPlan, onFailure: @escaping @Sendable (Error?) -> Void) {
        databaseManager?.update(entity: entity, matchingWith: model, onFailure: onFailure)
    }
}
