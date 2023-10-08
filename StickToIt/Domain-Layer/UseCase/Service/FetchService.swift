//
//  FetchService.swift
//  StickToIt
//
//  Created by 서동운 on 10/7/23.
//

import Foundation

protocol FetchService {
    associatedtype Query
    associatedtype Model
    
    func fetchAll(completion: @escaping([Model]) -> Void)
    func fetch(query: Query, completion: @escaping (Model) -> Void)
}
