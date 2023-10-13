//
//  DayPlanRepositoryImpl.swift
//  StickToIt
//
//  Created by 서동운 on 10/12/23.
//

import Foundation

enum FileManagerError: Error {
    case invalidDirectory
    case emptyData
    case fileSaveError
    case fileIsNil
}

struct DayPlanRepositoryImpl {

    // MARK: Properties
    private let networkService: NetworkService?
    private let databaseManager: DayPlanDataBaseManager?

    // MARK: Life Cycle
    init(
        networkService: NetworkService?,
        databaseManager: DayPlanDataBaseManager?
    ) {
        self.networkService = networkService
        self.databaseManager = databaseManager
    }
}

extension DayPlanRepositoryImpl: PlanRepository {
   
    typealias Model = DayPlan
    typealias Entity = DayPlanEntity
    typealias Query = PlanQuery
    
    func fetchAll() -> Result<[Model], Error> {
        guard let entities = databaseManager?.fetchAll() else { return .failure((NSError(domain: "fetchAll Error", code: 1000))) }
        return .success(entities.map { $0.toDomain() })
    }
    
    func fetch(query: PlanQuery) -> Result<Model, Error> {
        guard let entity = databaseManager?.fetch(key: query.planID) as? DayPlanEntity else { return .failure(NSError(domain: "fetch Error", code: 1000)) }
        return .success(entity.toDomain())
    }
    
    func create(model: Model, completion: @Sendable @escaping (Result<Bool, Error>) -> Void) {
        databaseManager?.create(model: model, to: DayPlanEntity.self, onFailure: { error in
            if let error {
                return completion(.failure(error))
            }
            return completion(.success(true))
        })
    }
    
    func update(entity: DayPlanEntity.Type, matchingWith model: DayPlan, onFailure: @escaping @Sendable (Error?) -> Void) {
        print(model, entity)
        databaseManager?.update(entity: entity, matchingWith: model, onFailure: onFailure)
    }
    
    func saveImage(path fileName: String, imageData: Data?) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileManagerError.invalidDirectory }
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        guard let imageData else { throw FileManagerError.emptyData }
        do {
            try imageData.write(to: fileURL)
        } catch {
            throw FileManagerError.fileSaveError
        }
    }
    
    func loadImageFromDocument(fileName: String) throws -> Data? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileManagerError.invalidDirectory  }
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return try? Data(contentsOf: fileURL)
        } else {
            throw FileManagerError.fileIsNil
        }
    }
    
    func deleteImageFromDocument(fileName: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileManagerError.invalidDirectory }
        let fileURL = documentDirectory.appendingPathComponent( fileName)

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
