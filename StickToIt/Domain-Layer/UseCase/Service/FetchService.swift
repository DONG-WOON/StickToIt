//
//  FetchService.swift
//  StickToIt
//
//  Created by 서동운 on 10/7/23.
//

import Foundation

protocol FetchService<Query, Model, Entity> {
    associatedtype Query
    associatedtype Model
    associatedtype Entity
    
    func fetchAll(completion: @escaping([Model]) -> Void)
    func fetch(query: Query, completion: @escaping (Model) -> Void)
}
