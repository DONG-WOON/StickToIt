//
//  CreatePlanRepository.swift
//  StickToIt
//
//  Created by 서동운 on 10/7/23.
//

import Foundation

protocol CreatePlanRepository<Model, Entity, Query> {
    associatedtype Model
    associatedtype Entity
    associatedtype Query
    
    func create(model: Model, completion: @escaping (Result<Bool, Error>) -> Void)
}

