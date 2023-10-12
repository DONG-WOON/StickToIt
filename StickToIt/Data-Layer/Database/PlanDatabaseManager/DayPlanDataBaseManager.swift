//
//  DayPlanDataBaseManager.swift
//  StickToIt
//
//  Created by 서동운 on 10/12/23.
//

import Foundation
import RealmSwift


struct DayPlanDataBaseManager {
    
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

extension DayPlanDataBaseManager: DatabaseManager {
   
    typealias Model = DayPlan
    typealias Entity = DayPlanEntity
    typealias ResultType = Results<DayPlanEntity>
    typealias Key = UUID
    
    func fetchAll() -> Results<Entity> {
        let objects = asyncRealm.objects(Entity.self)
        return objects
    }
    
    func fetch(key: UUID) -> Entity? {
        let object = asyncRealm.object(ofType: Entity.self, forPrimaryKey: key)
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
    
    func update(entity: DayPlanEntity.Type, matchingWith model: DayPlan, onFailure: @escaping @Sendable (Error?) -> Void) {
        guard let fetchedEntity = fetch(key: model._id) else { return }
        asyncRealm.writeAsync {
            fetchedEntity.content = model.content
            fetchedEntity.date = model.date
            fetchedEntity.imageData = model.imageData
            fetchedEntity.isRequired = model.isRequired
            fetchedEntity.week = model.week
        } onComplete: { error in
            underlyingQueue.async {
                onFailure(error)
            }
        }
    }
    
    func delete(entity: DayPlanEntity.Type, matchingWith model: DayPlan, onFailure: @escaping @Sendable (Error?) -> Void) {
    
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
