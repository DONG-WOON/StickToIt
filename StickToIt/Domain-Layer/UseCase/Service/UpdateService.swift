//
//  UpdateService.swift
//  StickToIt
//
//  Created by 서동운 on 10/12/23.
//

import Foundation

protocol UpdateService {
    associatedtype Model
    associatedtype Entity
    
    func save(entity: Entity.Type, matchingWith model: Model, completion: @escaping (Result<Bool, Error>) -> Void)
}
