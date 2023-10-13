//
//  FetchPlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import Foundation

protocol FetchPlanUseCase: FetchService {
    func loadImageFromDocument(fileName: String, completion: @escaping (Data?) -> Void)
}

final class FetchPlanUseCaseImpl
< Repository: PlanRepository<Plan, PlanEntity, PlanQuery> >
: FetchPlanUseCase
{
    
    typealias Query = PlanQuery
    typealias Model = Plan
    typealias Repository = Repository
    
    let repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
//    func fetchAllR() -> Result<[Plan], Error> {
//        return repository.fetchAll()
//    }
    
    func fetchAll(completion: @escaping ([Plan]) -> Void) {
        let result = repository.fetchAll()
        switch result {
        case .success(let plans):
            completion(plans)
        case .failure(let error):
            print(error)
        }
    }
    
    func fetch(query: PlanQuery, completion: @escaping (Plan) -> Void) {
        let result = repository.fetch(query: query)
        switch result {
        case .success(let plan):
            completion(plan)
        case .failure(let error):
            print(error)
        }
    }
    
    func loadImageFromDocument(fileName: String, completion: @escaping (Data?) -> Void) {
        do {
            let data = try repository.loadImageFromDocument(fileName: fileName)
            completion(data)
        } catch {
            print(error)
        }
    }
}
