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
    private var asyncRealm: Realm!
    private let realmQueue: DispatchQueue = DispatchQueue(label: "realm.Queue")
    
    // MARK: Life Cycle
    init?() {
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
            
            try realmQueue.sync {
                self.asyncRealm = try Realm(
                    configuration: configuration,
                    queue: realmQueue
                )
            }
        } catch {
            fatalError("\(error)")
            return nil
        }
    }
    
    // MARK: Read
    func fetchAll<T: Object & Entity>(
        type: T.Type,
        completion: @escaping (Results<T>) -> Void
    ) {
        realmQueue.async {
            let objects = asyncRealm
                .objects(T.self)
            completion(objects)
        }
    }
    
    func fetch<T: Object & Entity>(
        type: T.Type,
        key: UUID,
        completion: @escaping (T?) -> Void
    ) {
        realmQueue.async {
           
            let object = asyncRealm
                .object(
                    ofType: T.self,
                    forPrimaryKey: key
                )
            completion(object)
        }
    }
    
    // MARK: Create
    func create<U: Model & Identifiable<UUID>, T: Entity>(
        model: U,
        to entity: T.Type,
        onComplete: @Sendable @escaping (Error?) -> Void
    ) {
        realmQueue.async {
            asyncRealm.writeAsync {
                asyncRealm.add(
                    model.toEntity()
                )
            } onComplete: { error in
                    onComplete(error)
            }
        }
    }
    
    // MARK: Update
    
    func update<T: Object & Entity>(
        entity: T.Type,
        key: UUID,
        updateHandler: @escaping (T?) -> Void,
        onComplete: @Sendable @escaping (Error?) -> Void
    ) {
        fetch(type: entity.self, key: key, completion: { entity in
            asyncRealm.writeAsync {
                updateHandler(entity)
            } onComplete: { error in
                onComplete(error)
            }
        })
    }
    
    // MARK: Delete
    func delete<T: Object & Entity>(
        entity: T.Type,
        key: UUID,
        deleteHandler: @escaping (Realm, T?) -> Void,
        onComplete: @escaping @Sendable (Error?) -> Void
    ) {
        fetch(type: entity, key: key) { entity in
           
            asyncRealm.writeAsync {
                deleteHandler(asyncRealm, entity)
            } onComplete: { error in
                onComplete(error)
            }
        }
    }
    
    func delete<T: Object & Entity>(
        entity: T.Type,
        key: UUID,
        onComplete: @escaping @Sendable (Error?) -> Void
    ) {
        fetch(type: entity, key: key) {entity in
            guard let _entity = entity else {
                onComplete(DatabaseError.deleteError)
                return
            }
            asyncRealm.writeAsync {
                asyncRealm.delete(_entity)
            } onComplete: { error in
                onComplete(error)
            }
        }
    }
    
    func deleteAll(onComplete: @escaping @Sendable (Error?) -> Void) {
        realmQueue.async {
            
            asyncRealm.writeAsync {
                asyncRealm.deleteAll()
            } onComplete: { error in
                onComplete(error)
            }
        }
    }
}
