//
//  DatabaseManager.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation

protocol DatabaseManager {
    
    associatedtype Model
    associatedtype Entity
    associatedtype ResultType
    associatedtype Key
    
    // MARK: Methods
    func fetchAll() -> ResultType
    func fetch(key: Key) -> Entity?
    func create(model: Model, to entity: Entity.Type, onFailure: @Sendable @escaping (Error?) -> Void)
    func update(entity: Entity.Type, matchingWith model: Model, updateHandler: @escaping (Entity) -> Void, onFailure: @Sendable @escaping (Error?) -> Void) 
    func delete(entity: Entity.Type, matchingWith model: Model, onFailure: @Sendable @escaping (Error?) -> Void)
    func deleteAll()
}
