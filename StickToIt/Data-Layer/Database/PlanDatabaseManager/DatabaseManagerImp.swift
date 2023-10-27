//
//  DatabaseManagerImp.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation
import RealmSwift

struct DatabaseManagerImp: DatabaseManager {
    
    
    // MARK: Properties
    private let asyncRealm: Realm
    private let realmQueue = DispatchQueue(label: "realm.Queue")
    private let underlyingQueue: DispatchQueue
    
    // MARK: Life Cycle
    init?(underlyingQueue: DispatchQueue = .main) {
        do {
            guard let directory = FileManager.default
                .urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                ).first
            else {
                throw DatabaseError.invalidDirectory
            }
            
            let realmURL = directory.appendingPathComponent("default.realm")
            
            let configuration = Realm.Configuration(
                fileURL: realmURL,
                schemaVersion: 0
            ) { (migration, oldSchemaVersion) in
                
            }
            
            self.underlyingQueue = underlyingQueue
            self.asyncRealm = try Realm(
                configuration: configuration,
                queue: underlyingQueue
            )
        } catch {
            fatalError("\(error)")
            return nil
        }
    }
    
    // MARK: Read
    func fetchAll<T: Object & Entity>(type: T.Type) -> Results<T> {
        let objects = asyncRealm
            .objects(T.self)
        return objects
    }
    
    func fetch<T: Object & Entity>(type: T.Type, key: UUID) -> T? {
        let object = asyncRealm
            .object(
                ofType: T.self,
                forPrimaryKey: key
            )
        return object
    }
    
    func filteredFetch<T: Object & Entity>(
        type: T.Type,
        _ filtered: (T) -> Bool
    ) -> [T] {
        let object = asyncRealm
            .objects(T.self)
            .filter(filtered)
        return object
    }
    
    // MARK: Create
    func create<U: Model & Identifiable<UUID>, T: Entity>(
        model: U,
        to entity: T.Type,
        onFailure: @Sendable @escaping (Error?) -> Void
    ) {
        asyncRealm.writeAsync {
            self.asyncRealm.add(
                model.toEntity()
            )
        } onComplete: { error in
            underlyingQueue.async {
                onFailure(error)
            }
        }
    }
    
    // MARK: Update
    func update<U: Model & Identifiable<UUID>, T: Object & Entity>(
        entity: T.Type,
        matchingWith model: U,
        updateHandler: @escaping (T) -> Void,
        onFailure: @escaping @Sendable (Error?) -> Void
    ) {
        guard let fetchedEntity = fetch(type: entity.self, key: model.id) else {
            onFailure(DatabaseError.update)
            return
        }
        asyncRealm.writeAsync {
            updateHandler(fetchedEntity)
        } onComplete: { error in
            underlyingQueue.async {
                onFailure(error)
            }
        }
    }
    
    func update<T: Object & Entity>(
        entity: T.Type,
        key: UUID,
        updateHandler: @escaping (T) -> Void,
        onFailure: @Sendable @escaping (Error?) -> Void
    ) {
        guard let fetchedEntity = fetch(type: entity.self, key: key) else {
            onFailure(DatabaseError.update)
            return
        }
        asyncRealm.writeAsync {
            updateHandler(fetchedEntity)
        } onComplete: { error in
            underlyingQueue.async {
                onFailure(error)
            }
        }
    }
    
    // MARK: Delete
    func delete<U: Model & Identifiable<UUID>, T: Object & Entity>(
        entity: T.Type,
        matchingWith model: U,
        deleteHandler: @escaping (T) -> Void,
        onFailure: @escaping @Sendable (Error?) -> Void
    ) {
        guard let fetchedEntity = fetch(type: entity, key: model.id) else {
            onFailure(DatabaseError.delete)
            return
        }
        
        asyncRealm.writeAsync {
            deleteHandler(fetchedEntity)
        } onComplete: { error in
            underlyingQueue.async {
                onFailure(error)
            }
        }
    }
    
    func deleteAll() {
        asyncRealm.deleteAll()
    }
}
