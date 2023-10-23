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
        guard let entities = databaseManager?.fetchAll() else { return .failure((NSError(domain: "\nfetch All Error, \nfile: \(#file), \nfunction: \(#function), \nline: \(#line)", code: 1000))) }
        return .success(entities.map { $0.toDomain() })
    }
    
    func fetch(query: PlanQuery) -> Result<Model, Error> {
        guard let entity = databaseManager?.fetch(key: query.planID) as? DayPlanEntity else { return .failure(NSError(domain: "\nfetch Error, \nfile: \(#file), \nfunction: \(#function), \nline: \(#line)", code: 1000)) }
        return .success(entity.toDomain())
    }
    
    func filteredFetch(filtered: (Entity) -> Bool) -> Result<[Model], Error> {
        guard let entity = databaseManager?.filteredFetch(filtered) else { return .failure(NSError(domain: "filtered error", code: -1000))}
        return .success(entity.map { $0.toDomain() })
    }
    
    
    func create(model: Model, completion: @Sendable @escaping (Result<Bool, Error>) -> Void) {
        databaseManager?.create(model: model, to: DayPlanEntity.self, onFailure: { error in
            if let error {
                return completion(.failure(error))
            }
            return completion(.success(true))
        })
    }
    
    func update(entity: DayPlanEntity.Type, matchingWith model: DayPlan, updateHandler: @escaping (Entity)-> Void,  onFailure: @escaping @Sendable (Error?) -> Void) {
        databaseManager?.update(entity: entity, matchingWith: model, updateHandler: updateHandler, onFailure: onFailure)
    }
    
    func saveImage(path fileName: String, imageData: Data?) async throws -> String? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileManagerError.invalidDirectory }
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
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileManagerError.invalidDirectory  }
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).jpeg")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return try Data(contentsOf: fileURL)
        } else {
            return nil
        }
    }
    
    func deleteImageFromDocument(fileName: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileManagerError.invalidDirectory }
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
    
    func save(planQuery: PlanQuery, to user: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        return
    }
    
}
