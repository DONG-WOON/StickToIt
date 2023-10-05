//
//  PlanRepository.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation

protocol PlanRepository {
    
    func fetchAll() -> Result<[Plan], Error>
    func fetch(query: PlanQuery) -> Result<Plan, Error>
    func create(model: Plan, completion: @escaping (Result<Bool, Error>) -> Void)
}
