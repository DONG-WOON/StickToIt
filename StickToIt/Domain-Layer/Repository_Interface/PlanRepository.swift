//
//  PlanRepository.swift
//  StickToIt
//
//  Created by 서동운 on 10/7/23.
//

import Foundation
import RealmSwift

protocol PlanRepository<Model, Entity> {
    
    associatedtype Model
    associatedtype Entity
    
    func fetchAll() -> Result<[Model], Error>
    
    func fetch(
        key: UUID
    ) -> Result<Model, Error>
    
    func create(
        model: Model,
        completion: @Sendable @escaping (Result<Bool, Error>) -> Void
    )
    
    func update(
        entity: Entity.Type,
        matchingWith model: Model,
        updateHandler: @escaping (Entity) -> Void,
        onComplete: @Sendable @escaping (Error?) -> Void
    )
    
    func delete(
        entity: Entity.Type,
        key: UUID,
        deleteHandler: @escaping (Realm, Entity) -> Void,
        onComplete: @escaping @Sendable (Error?) -> Void
    )
    
    func delete(
        entity: Entity.Type,
        key: UUID,
        onComplete: @escaping @Sendable (Error?) -> Void
    )
    
    func saveImageData(
        _ imageData: Data?,
        path fileName: String
    ) async throws -> String?
    
    func loadImageFromDocument(
        fileName: String
    ) throws -> Data?
}
