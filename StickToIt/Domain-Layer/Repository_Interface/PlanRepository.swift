//
//  PlanRepository.swift
//  StickToIt
//
//  Created by 서동운 on 10/7/23.
//

import Foundation

protocol PlanRepository<Model, Entity, Query> {
    associatedtype Model
    associatedtype Entity
    associatedtype Query
    
    func fetchAll() -> Result<[Model], Error>
    func fetch(query: PlanQuery) -> Result<Model, Error>
    func create(model: Model, completion: @Sendable @escaping (Result<Bool, Error>) -> Void)
    func update(entity: Entity.Type, matchingWith model: Model, onFailure: @Sendable @escaping (Error?) -> Void) 
}

