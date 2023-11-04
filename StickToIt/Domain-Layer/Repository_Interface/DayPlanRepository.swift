//
//  DayPlanRepository.swift
//  StickToIt
//
//  Created by 서동운 on 10/28/23.
//

import Foundation

protocol DayPlanRepository<Model, Entity> {
    
    associatedtype Model
    associatedtype Entity
    
    func create(
        model: Model,
        completion: @Sendable @escaping (Result<Bool, Error>) -> Void
    )
    
    func update(
        entity: Entity.Type,
        key: UUID,
        updateHandler: @escaping (Entity?)-> Void,
        onComplete: @escaping @Sendable (Error?) -> Void
    )
    
    func saveImageData(
        _ imageData: Data?,
        path fileName: String
    ) async throws -> String?
    
    func loadImageFromDocument(fileName: String) throws -> Data?
    
    func deleteImageFromDocument(fileName: String) throws
}

