//
//  PlanQueryRepositoryImp.swift
//  StickToIt
//
//  Created by 서동운 on 10/29/23.
//

import Foundation
import RealmSwift

struct PlanQueryRepositoryImp {

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

extension PlanQueryRepositoryImp: PlanRepository {
    
    typealias Model = PlanQuery
    typealias Entity = PlanQueryEntity
    
    func fetchAll(completion: @escaping (Result<[Model], Error>) -> Void) {
        databaseManager?.fetchAll(type: Entity.self) { results in
            let entity = results.compactMap { $0 }
            completion(.success(entity.map({ $0.toDomain() })))
        }
    }
    
    func fetch(key: UUID, completion: @escaping (Result<Model, Error>) -> Void) {
        databaseManager?.fetch(type: Entity.self, key: key) { entity in
            guard let _entity = entity?.toDomain() else {
                completion(.failure(DatabaseError.fetchError))
                return
            }
            completion(.success(_entity))
        }
    }
    
    func create(
        model: Model,
        completion: @Sendable @escaping (Result<Bool, Error>) -> Void
    ) {
        databaseManager?.create(
            model: model,
            to: PlanEntity.self,
            onComplete: { error in
                if let error {
                    return completion(.failure(error))
                }
                return completion(.success(true))
            })
    }
    
    func update(
        entity: Entity.Type,
        key: UUID,
        updateHandler: @escaping (Entity?) -> Void,
        onComplete: @escaping @Sendable (Error?) -> Void
    ) {
        databaseManager?.update(
            entity: entity,
            key: key,
            updateHandler: updateHandler,
            onComplete: onComplete
        )
    }
    
    func delete(
        entity: Entity.Type,
        key: UUID,
        onComplete: @escaping @Sendable (Error?) -> Void
    ) {
        databaseManager?.delete(
            entity: entity,
            key: key,
            onComplete: onComplete
        )
    }
    
    func delete(
        entity: Entity.Type,
        key: UUID,
        deleteHandler: @escaping (Realm, Entity?) -> Void,
        onComplete: @escaping @Sendable (Error?) -> Void
    ) {
        databaseManager?.delete(
            entity: entity,
            key: key,
            deleteHandler: deleteHandler,
            onComplete: onComplete
        )
    }
    
    func saveImageData(
        _ imageData: Data?,
        path fileName: String
    ) async throws -> String? {
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
