//
//  UserRepositoryImpl.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import Foundation

struct UserRepositoryImpl {

    // MARK: Properties
    private let networkService: NetworkService?
    private let databaseManager: UserDatabaseManager?

    // MARK: Life Cycle
    init(
        networkService: NetworkService?,
        databaseManager: UserDatabaseManager?
    ) {
        self.networkService = networkService
        self.databaseManager = databaseManager
    }
}

extension UserRepositoryImpl: UserRepository {
    typealias Model = User
    typealias Entity = UserEntity
    typealias ID = UUID

    func fetch(key: ID) -> Result<Model, Error> {
        guard let entity = databaseManager?.fetch(key: key) else {
            return .failure(NSError(domain: "User Not Found", code: -1000))
        }
        return .success(entity.toDomain())
    }
    
    func create(model: Model, completion: @Sendable @escaping (Result<Bool, Error>) -> Void) {
        databaseManager?.create(model: model, to: Entity.self, onFailure: { error in
            if let error {
                return completion(.failure(error))
            }
            return completion(.success(true))
        })
    }
    
    func update(entity: Entity.Type, matchingWith model: Model, updateHandler: @escaping (Entity) -> Void, onFailure: @escaping @Sendable (Error?) -> Void) {
        databaseManager?.update(entity: entity, matchingWith: model, updateHandler: updateHandler, onFailure: onFailure)
    }
}
