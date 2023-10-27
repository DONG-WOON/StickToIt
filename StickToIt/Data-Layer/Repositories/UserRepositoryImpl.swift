//
//  UserRepositoryImp.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import Foundation

struct UserRepositoryImp {

    // MARK: Properties
    private let networkService: NetworkService?
    private let databaseManager: DatabaseManager?

    // MARK: Life Cycle
    init(
        networkService: NetworkService?,
        databaseManager: DatabaseManager?
    ) {
        self.networkService = networkService
        self.databaseManager = databaseManager
    }
}

extension UserRepositoryImp: UserRepository {
    typealias Model = User
    typealias Entity = UserEntity
    typealias ID = UUID

    func fetch(key: ID) -> Result<Model, Error> {
        guard let entity = databaseManager?
            .fetch(type: Entity.self, key: key)
        else {
            return .failure(DatabaseError.fetch)
        }
        return .success(entity.toDomain())
    }
    
    func create(model: Model, completion: @Sendable @escaping (Result<Bool, Error>) -> Void) {
        databaseManager?.create(
            model: model,
            to: Entity.self,
            onFailure: { error in
                if let error {
                    return completion(.failure(error))
                }
                return completion(.success(true))
            }
        )
    }
    
    func update(
        entity: Entity.Type,
        matchingWith model: Model,
        updateHandler: @escaping (Entity) -> Void,
        onFailure: @escaping @Sendable (Error?) -> Void
    ) {
        databaseManager?.update(
            entity: entity,
            matchingWith: model,
            updateHandler: updateHandler,
            onFailure: onFailure
        )
    }
    
    func update(
        userID: ID,
        updateHandler: @escaping (Entity) -> Void,
        onFailure: @Sendable @escaping (Error?) -> Void
    ) {
        databaseManager?.update(
            entity: Entity.self,
            key: userID,
            updateHandler: updateHandler,
            onFailure: onFailure
        )
    }
}
