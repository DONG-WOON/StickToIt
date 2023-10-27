//
//  UserRepository.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import Foundation

protocol UserRepository<Model, Entity, ID> {
    
    associatedtype Model
    associatedtype Entity
    associatedtype ID
    
    func fetch(key: ID) -> Result<Model, Error>
    func create(
        model: Model,
        completion: @Sendable @escaping (Result<Bool, Error>) -> Void
    )
    
    func update(
        entity: Entity.Type,
        matchingWith model: Model,
        updateHandler: @escaping (Entity) -> Void,
        onFailure: @Sendable @escaping (Error?) -> Void
    )
    
    func update(
        userID: ID,
        updateHandler: @escaping (Entity) -> Void,
        onFailure: @Sendable @escaping (Error?) -> Void
    )
}

