//
//  PlanRepositoryImp.swift
//  StickToIt
//
//  Created by 서동운 on 10/10/23.
//

import Foundation

struct PlanRepositoryImp {

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

extension PlanRepositoryImp: PlanRepository {
    
    typealias Model = Plan
    typealias Entity = PlanEntity
    typealias Query = PlanQuery
    
    func fetchAll() -> Result<[Model], Error> {
        guard let entities = databaseManager?
            .fetchAll(type: Entity.self)
        else {
            return .failure(DatabaseError.fetchAll)
        }
        return .success(entities.map { $0.toDomain() })
    }
    
    func fetch(query: PlanQuery) -> Result<Model, Error> {
        guard let entity = databaseManager?
            .fetch(type: Entity.self, key: query.id)
        else {
            return .failure(DatabaseError.fetch)
        }
        return .success(entity.toDomain())
    }
    
    func create(
        model: Model,
        completion: @Sendable @escaping (Result<Bool, Error>) -> Void
    ) {
        databaseManager?.create(
            model: model,
            to: PlanEntity.self,
            onFailure: { error in
                if let error {
                    return completion(.failure(error))
                }
                return completion(.success(true))
            })
    }
    
    func update(
        entity: PlanEntity.Type,
        matchingWith model: Plan,
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
    
    func saveImage(path fileName: String, imageData: Data?) async throws -> String? {
        return nil
    }
    
    func loadImageFromDocument(fileName: String) throws -> Data? {
        guard let documentDirectory = FileManager.default
            .urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
        else { throw FileManagerError.invalidDirectory }
        
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).jpeg")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return try? Data(contentsOf: fileURL)
        } else {
            throw FileManagerError.fileIsNil
        }
    }
}
