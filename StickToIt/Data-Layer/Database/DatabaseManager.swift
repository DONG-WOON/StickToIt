//
//  DatabaseManager.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation
import RealmSwift

protocol DatabaseManager {
    associatedtype Model
    associatedtype Entity
    associatedtype ResultsType
    
    func fetchAll() -> ResultsType
    func fetch(key: UUID) -> Entity?
    func create(model: Model, to entity: Entity.Type, onFailure: @escaping (Error?) -> Void)
    func update(entity: Entity.Type, matchingWith model: Model)
    func delete(entity: Entity.Type, matchingWith model: Model)
    func deleteAll()
}

extension DatabaseManager {
    func deleteAll() {
        #warning("전체삭제를 미리 구현해놓고 싶지만 Realm 객체를 DatabaseManager의 private property로 관리하고 있음")
    }
}
