//
//  DayPlanRepositoryImpl.swift
//  StickToIt
//
//  Created by 서동운 on 10/12/23.
//

import Foundation

struct DayPlanRepositoryImp {

    // MARK: Properties
    private let networkService: NetworkService?
    private let databaseManager: DatabaseManager?

    // MARK: Life Cycle
    init(
        networkService: NetworkService?,
        databaseManager: DatabaseManager?
    ) {
        self.networkService = networkService
        self.databaseManager = databaseManager
    }
}

extension DayPlanRepositoryImp: DayPlanRepository {
   
    typealias Model = DayPlan
    typealias Entity = DayPlanEntity
    
    func create(
        model: Model,
        completion: @Sendable @escaping (Result<Bool, Error>) -> Void
    ) {
        databaseManager?.create(
            model: model,
            to: Entity.self,
            onComplete: { error in
                if let error {
                    return completion(.failure(error))
                }
                return completion(.success(true))
            }
        )
    }
    
    func update(
        entity: DayPlanEntity.Type,
        key: UUID,
        updateHandler: @escaping (Entity)-> Void,
        onComplete: @escaping @Sendable (Error?) -> Void
    ) {
        databaseManager?.update(
            entity: entity,
            key: key,
            updateHandler: updateHandler,
            onComplete: onComplete
        )
    }
    
    func saveImageData(
        _ imageData: Data?,
        path fileName: String
    ) async throws -> String? {
        guard let documentDirectory = FileManager.default
            .urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
        else { throw FileManagerError.invalidDirectory }
        
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).jpeg")
        guard let imageData else { throw FileManagerError.emptyData }
        
        do {
            try imageData.write(to: fileURL)
            return fileURL.absoluteString
        } catch {
            throw FileManagerError.fileSaveError
        }
    }
    
    func loadImageFromDocument(fileName: String) throws -> Data? {
        guard let documentDirectory = FileManager.default
            .urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
        else { throw FileManagerError.invalidDirectory }
        
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).jpeg")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return try Data(contentsOf: fileURL)
        } else {
            return nil
        }
    }
    
    func deleteImageFromDocument(fileName: String) throws {
        guard let documentDirectory = FileManager.default
            .urls(
                for: .documentDirectory,
                in: .userDomainMask)
                .first
        else { throw FileManagerError.invalidDirectory }
        
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch {
                throw error
            }
        } else {
            return
        }
    }
}
