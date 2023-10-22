//
//  UserDatabaseManager.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import Foundation
import RealmSwift
import Realm

struct UserDatabaseManager {
    
    // MARK: Properties
    private let asyncRealm: Realm
    private let realmQueue = DispatchQueue(label: "realm.Queue")
    private let underlyingQueue: DispatchQueue
    
    // MARK: Life Cycle
    init?(underlyingQueue: DispatchQueue = .main) {
        do {
            guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw RealmError.invalidDirectory }
            let realmURL = directory.appendingPathComponent("default.realm")
            
            let configuration = Realm.Configuration(fileURL: realmURL, schemaVersion: 0)
            { (migration, oldSchemaVersion) in
                
            }
            self.underlyingQueue = underlyingQueue
            self.asyncRealm = try Realm(configuration: configuration, queue: underlyingQueue)
        } catch {
            fatalError("\(error)")
            return nil
        }
    }
}

extension UserDatabaseManager: DatabaseManager {
    
    typealias Model = User
    typealias Entity = UserEntity
    typealias ResultType = Results<UserEntity>
    typealias Key = UUID
    
    func fetchAll() -> RealmSwift.Results<UserEntity> {
        let objects = asyncRealm.objects(Entity.self)
        return objects
    }
    
    func fetch(key: UUID) -> UserEntity? {
        let object = asyncRealm.object(ofType: Entity.self, forPrimaryKey: key)
        return object
    }
    
    func filteredFetch(_ filtered: (UserEntity) -> Bool) -> [UserEntity] {
        let objects = asyncRealm.objects(UserEntity.self).filter(filtered)
        return objects
    }
    
    func create(model: User, to entity: UserEntity.Type, onFailure: @escaping @Sendable (Error?) -> Void) {
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
    
    func update(entity: UserEntity.Type, matchingWith model: User, updateHandler: @escaping (Entity) -> Void, onFailure: @escaping @Sendable (Error?) -> Void) {
        guard let fetchedEntity = fetch(key: model._id) else { return }
        asyncRealm.writeAsync {
            updateHandler(fetchedEntity)
        } onComplete: { error in
            underlyingQueue.async {
                onFailure(error)
            }
        }
    }
    
    func update(key: Key, updateHandler: @escaping (Entity) -> Void, onFailure: @escaping @Sendable (Error?) -> Void) {
        guard let fetchedEntity = fetch(key: key) else { return }
        
        asyncRealm.writeAsync {
            updateHandler(fetchedEntity)
        } onComplete: { error in
            underlyingQueue.async {
                onFailure(error)
            }
        }
    }
    
    func delete(entity: UserEntity.Type, matchingWith model: User, onFailure: @escaping @Sendable (Error?) -> Void) {
        guard let fetchedEntity = fetch(key: model._id) else { return }
        
        //삭제는 동기로 해야할지도!
        asyncRealm.writeAsync {
            // db 삭제 chaining delete
            let dayPlans = fetchedEntity

            self.asyncRealm.delete(dayPlans)
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
