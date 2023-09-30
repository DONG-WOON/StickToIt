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

final class PlanDatabaseManager: DatabaseManager {
    
    typealias ResultsType = Results<PlanEntity>
    typealias Model = Plan
    typealias Entity = PlanEntity
    
    private let asyncRealm: Realm
    
    init?(queue: DispatchQueue) {
        do {
            guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw RealmError.invalidDirectory }
            let realmURL = directory.appendingPathComponent("default.realm")
            
            let configuration = Realm.Configuration(fileURL: realmURL, schemaVersion: 0)
            { (migration, oldSchemaVersion) in
                
            }
            self.asyncRealm = try Realm(configuration: configuration, queue: .main)
        } catch {
            return nil
        }
    }
    
    func fetchAll() -> Results<PlanEntity> {
        let objects = asyncRealm.objects(PlanEntity.self)
        return objects
    }
    
    func fetch(key: UUID) -> PlanEntity? {
        let object = asyncRealm.object(ofType: PlanEntity.self, forPrimaryKey: key)
        return object
    }
    
    func create(model: Model, to entity: Entity.Type, onFailure: @escaping (Error?) -> Void) {
        asyncRealm.writeAsync {
            self.asyncRealm.add(
                Entity(
                    title: model.title,
                    targetWeek: model.targetWeek,
                    startDate: model.startDate
                )
            )
        } onComplete: { error in
            onFailure(error)
        }
    }
    
    func update(entity: Entity.Type, matchingWith model: Plan) {
        guard let fetchedEntity = fetch(key: model._id) else { return }
        asyncRealm.writeAsync {
            fetchedEntity.startDate = model.startDate
            fetchedEntity.targetWeek = model.targetWeek
            fetchedEntity.title = model.title
        } onComplete: { error in
            print(error as Any)
        }
    }
    
    func delete(entity: Entity.Type, matchingWith model: Plan) {
        guard let fetchedEntity = fetch(key: model._id) else { return }
        
        //삭제는 동기로 해야할지도!
        asyncRealm.writeAsync {
            // db 삭제 chaining delete
            let weeklyPlans = fetchedEntity.weeklyPlans
            weeklyPlans.forEach { weeklyPlan in
                self.asyncRealm.delete(weeklyPlan.dayPlans)
            }
            self.asyncRealm.delete(weeklyPlans)
            self.asyncRealm.delete(fetchedEntity)
        }
    }
}
