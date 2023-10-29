//
//  FetchPlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import Foundation

protocol FetchPlanUseCase<Model, Entity> {
    
    associatedtype Model
    associatedtype Entity
    
    func fetchAll(completion: @escaping ([Model]) -> Void)
    
    func fetch(
        key: UUID,
        completion: @escaping (Model) -> Void
    )
    
    func loadImageFromDocument(
        fileName: String,
        completion: @escaping (Data?) -> Void
    )
}

final class FetchPlanUseCaseImp: FetchPlanUseCase {
    
    typealias Model = Plan
    typealias Entity = PlanEntity
    
    let repository: (any PlanRepository<Model, Entity>)
    
    init(repository: some PlanRepository<Model, Entity>) {
        self.repository = repository
    }

    // MARK: Fetch Service
    
    func fetchAll(completion: @escaping ([Model]) -> Void) {
        let result = repository.fetchAll()
        switch result {
        case .success(let plans):
            completion(plans)
        case .failure(let error):
            print(error)
        }
    }
    
    func fetch(
        key: UUID,
        completion: @escaping (Model) -> Void
    ) {
        let result = repository.fetch(key: key)
        switch result {
        case .success(let plan):
            completion(plan)
        case .failure(let error):
            print(error)
        }
    }
    
    func loadImageFromDocument(
        fileName: String,
        completion: @escaping (Data?) -> Void
    ) {
        do {
            let data = try repository.loadImageFromDocument(fileName: fileName)
            completion(data)
        } catch {
            print(error)
        }
    }
}
