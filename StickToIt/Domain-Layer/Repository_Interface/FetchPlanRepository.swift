//
//  FetchPlanRepository.swift
//  StickToIt
//
//  Created by 서동운 on 10/7/23.
//

import Foundation

protocol RepositoryElementConfigurable {
    associatedtype Model
    associatedtype Entity
    associatedtype Query
}


protocol FetchPlanRepository<Model, Entity, Query>: RepositoryElementConfigurable {
    
    func fetchAll() -> Result<[Model], Error>
    func fetch(query: Query) -> Result<Model, Error>
}
