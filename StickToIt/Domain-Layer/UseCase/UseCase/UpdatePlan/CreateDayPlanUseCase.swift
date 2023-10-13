//
//  CreateDayPlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/12/23.
//

import Foundation

protocol CreateDayPlanUseCase: UpdateService {
    func save(dayPlanID: UUID, imageData: Data?)
    func loadImage(dayPlanID: UUID, completion: @escaping (Data?) -> Void)
}

final class CreateDayPlanUseCaseImpl<
    Repository: PlanRepository<DayPlan, DayPlanEntity, PlanQuery>
>: CreateDayPlanUseCase {
    
    typealias Repository = Repository
    typealias Model = DayPlan
    typealias Entity = DayPlanEntity
    
    // MARK: Properties
    let repository: Repository
    
    // MARK: Life Cycle
    init(repository: Repository) {
        self.repository = repository
    }
    
    func save(entity: DayPlanEntity.Type, matchingWith model: DayPlan, completion: @Sendable @escaping (Result<Bool, Error>) -> Void) {
        repository.update(entity: entity, matchingWith: model) { error in
            guard let error else {
                return completion(.success(true))
            }
            return completion(.failure(error))
        }
    }
    
    func save(dayPlanID: UUID, imageData: Data?) {
        do {
            try repository.saveImage(path: dayPlanID.uuidString, imageData: imageData)
        } catch {
            print(error)
        }
    }
    
    func loadImage(dayPlanID: UUID, completion: @escaping (Data?) -> Void) {
        do {
            let data = try repository.loadImageFromDocument(fileName: dayPlanID.uuidString)
            completion(data)
        } catch {
            print(error)
        }
    }
}

