//
//  HomePlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import Foundation

final class HomePlanUseCase {
    
    private let planRepository: PlanRepository
    
    init(
        planRepository: PlanRepository
    ) {
        self.planRepository = planRepository
    }
}

extension HomePlanUseCase: PlanUseCase {
    
    func createPlan(_ model: Plan) {
        planRepository.create(model: model) { result in
            switch result {
            case .success:
                print("save", model._id)
                return
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchAllPlans(completion: @escaping ([Plan]) -> Void) {
        let result = planRepository.fetchAll()
        switch result {
        case .success(let plans):
            completion(plans)
        case .failure(let error):
            print(error)
        }
    }
    
    func fetchPlan(query: PlanQuery, completion: @escaping (Plan) -> Void) {
        print("fetch",query.planID)
        let result = planRepository.fetch(query: query)
        switch result {
        case .success(let plan):
            completion(plan)
        case .failure(let error):
            print(error)
        }
    }
}
