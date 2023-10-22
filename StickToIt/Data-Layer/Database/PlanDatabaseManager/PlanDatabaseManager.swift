//
//  PlanDatabaseManager.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation
import RealmSwift

enum RealmError: Error {
    case invalidDirectory
}

struct PlanDatabaseManager {
    
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

extension PlanDatabaseManager: DatabaseManager {
    
    typealias Model = Plan
    typealias Entity = PlanEntity
    typealias ResultType = Results<PlanEntity>
    typealias Key = UUID
    
    func fetchAll() -> Results<PlanEntity> {
        let objects = asyncRealm.objects(PlanEntity.self)
        return objects
    }
    
    func fetch(key: UUID) -> PlanEntity? {
        let object = asyncRealm.object(ofType: PlanEntity.self, forPrimaryKey: key)
        return object
    }
    
    func filteredFetch(_ filtered: (PlanEntity) -> Bool) -> [PlanEntity] {
        let object = asyncRealm.objects(PlanEntity.self).filter(filtered)
        return object
    }
    
    func create(model: Model, to entity: Entity.Type, onFailure: @Sendable @escaping (Error?) -> Void) {
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
    
    func update(entity: Entity.Type, matchingWith model: Plan, updateHandler: @escaping (Entity) -> Void, onFailure: @Sendable @escaping (Error?) -> Void) {
        guard let fetchedEntity = fetch(key: model._id) else { return }
        asyncRealm.writeAsync {
            updateHandler(fetchedEntity)
        } onComplete: { error in
            underlyingQueue.async {
                onFailure(error)
            }
        }
    }
    
    func delete(entity: Entity.Type, matchingWith model: Plan, onFailure: @Sendable @escaping (Error?) -> Void) {
        guard let fetchedEntity = fetch(key: model._id) else { return }
        
        //삭제는 동기로 해야할지도!
        asyncRealm.writeAsync {
            // db 삭제 chaining delete
            let dayPlans = fetchedEntity.dayPlans

            self.asyncRealm.delete(dayPlans)
            self.asyncRealm.delete(fetchedEntity)
        } onComplete: { error in
            underlyingQueue.async {
                onFailure(error)
            }
        }
    }
    
    func deleteAll() {
        asyncRealm.deleteAll()
    }
    
    func save(planQuery: PlanQuery, to user: Key, completion: @escaping (Result<Void, Error>) -> Void) {
        let userEntity = asyncRealm.object(ofType: UserEntity.self, forPrimaryKey: user)
        asyncRealm.writeAsync {
            userEntity?.planQueries.append(planQuery.toEntity())
        } onComplete: { error in
            
            if let error {
                completion(.failure(error))
            }
            return completion(.success(()))
        }
    }
}
