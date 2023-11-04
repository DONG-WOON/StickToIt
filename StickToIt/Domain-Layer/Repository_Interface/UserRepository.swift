//
//  UserRepository.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import Foundation

protocol UserRepository<Model, Entity> {
    
    associatedtype Model
    associatedtype Entity
    
    func fetch(
        key: UUID,
        completion: @escaping (Result<Model, Error>) -> Void
    )
    
    func create(
        model: Model,
        completion: @Sendable @escaping (Result<Bool, Error>) -> Void
    )
    
    func update(
        userID: UUID,
        updateHandler: @escaping (Entity?) -> Void,
        onComplete: @Sendable @escaping (Error?) -> Void
    )
    
    func deleteQuery(
        id: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    func deleteAll(onComplete: @escaping @Sendable (Error?) -> Void) 
}

