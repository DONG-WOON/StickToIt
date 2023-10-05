//
//  ShowPlanUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 9/30/23.
//

import Foundation

protocol PlanUseCase {
    func fetchAllPlans(completion: @escaping ([Plan]) -> Void)
    func fetchPlan(query: PlanQuery, completion: @escaping (Plan) -> Void)
    func createPlan(_ model: Plan)
}
