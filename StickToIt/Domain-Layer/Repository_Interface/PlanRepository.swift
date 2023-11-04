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
    
    func fetchAll(completion: @escaping (Result<[Model], Error>) -> Void)
    
    func fetch(
        key: UUID,
        completion: @escaping (Result<Model, Error>) -> Void
    )
    
    func create(
        model: Model,
        completion: @Sendable @escaping (Result<Bool, Error>) -> Void
    )
    
    func update(
        entity: Entity.Type,
        key: UUID,
        updateHandler: @escaping (Entity?) -> Void,
        onComplete: @Sendable @escaping (Error?) -> Void
    )
    
    func delete(
        entity: Entity.Type,
        key: UUID,
        deleteHandler: @escaping (Realm, Entity?) -> Void,
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
