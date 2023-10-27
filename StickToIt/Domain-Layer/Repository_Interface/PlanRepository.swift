//
//  PlanRepository.swift
//  StickToIt
//
//  Created by 서동운 on 10/7/23.
//

import Foundation

protocol PlanRepository<Query, Model, Entity> {
    
    associatedtype Model
    associatedtype Entity
    associatedtype Query
    
    func fetchAll() -> Result<[Model], Error>
    func fetch(query: Query) -> Result<Model, Error>
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
    
    func saveImage(path fileName: String, imageData: Data?) async throws -> String?
    func loadImageFromDocument(fileName: String) throws -> Data?
}
