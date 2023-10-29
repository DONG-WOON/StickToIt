//
//  UpdateDayPlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/12/23.
//

import Foundation

    func save(dayPlanID: UUID, imageData: Data?) async -> String?
    func loadImage(dayPlanID: UUID, completion: @escaping (Data?) -> Void)
protocol UpdateDayPlanUseCase<Model, Entity> {
}

final class UpdateDayPlanUseCaseImp: UpdateDayPlanUseCase {

    typealias Model = DayPlan
    typealias Entity = DayPlanEntity
    
    // MARK: Properties
    let repository: any DayPlanRepository<Model, Entity>
    
    // MARK: Life Cycle
    init(repository: some DayPlanRepository<Model, Entity>
    ) {
        self.repository = repository
    }
    
    func save(entity: DayPlanEntity.Type, matchingWith model: DayPlan, updateHandler: @escaping (Entity) -> Void) async -> Result<Bool, Error> {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { [weak self] in
                self?.repository.update(entity: entity, matchingWith: model, updateHandler: updateHandler, onFailure: { error in
                    if let error {
                        continuation.resume(returning: .failure(error))
                    }
                    continuation.resume(returning: .success(true))
                })
            }
        }
    }
    
    func save(dayPlanID: UUID, imageData: Data?) async -> String? {
        do {
            let url = try await repository.saveImage(path: dayPlanID.uuidString, imageData: imageData)
            return url
        } catch {
            print(error)
        }
        return nil
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

