//
//  CreatePlanRepositoryImpl.swift
//  StickToIt
//
//  Created by 서동운 on 10/7/23.
//

import Foundation

struct CreatePlanRepositoryImpl {

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

extension CreatePlanRepositoryImpl: CreatePlanRepository {
    typealias Model = Plan
    typealias Entity = PlanEntity
    typealias Query = PlanQuery
    
    func create(model: Plan, completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseManager?.create(model: model, to: PlanEntity.self, onFailure: { error in
            if let error {
                return completion(.failure(error))
            }
            return completion(.success(true))
        })
    }
}
