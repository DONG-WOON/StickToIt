//
//  UpdateDayPlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/12/23.
//

import Foundation

protocol UpdateDayPlanUseCase<Model, Entity> {
    
    associatedtype Model = DayPlan
    associatedtype Entity = DayPlanEntity
    
    func update(
        entity: DayPlanEntity.Type,
        matchingWith model: DayPlan,
        updateHandler: @escaping (Entity) -> Void
    ) async -> Result<Bool, Error>
    
    func saveImageData(
        _ imageData: Data?,
        dayPlanID: UUID
    ) async -> String?
    
    func loadImage(
        dayPlanID: UUID,
        completion: @escaping (Data?) -> Void
    )
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
    
    func update(
        entity: DayPlanEntity.Type,
        matchingWith model: DayPlan,
        updateHandler: @escaping (Entity) -> Void
    ) async -> Result<Bool, Error> {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { [weak self] in
                self?.repository.update(entity: entity, matchingWith: model, updateHandler: updateHandler, onComplete: { error in
                    if let error {
                        continuation.resume(returning: .failure(error))
                    }
                    continuation.resume(returning: .success(true))
                })
            }
        }
    }
    
    func saveImageData(_ imageData: Data?, dayPlanID: UUID) async -> String? {
        do {
            let url = try await repository.saveImageData(imageData, path: dayPlanID.uuidString)
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

