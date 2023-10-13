//
//  CreateService.swift
//  StickToIt
//
//  Created by 서동운 on 10/7/23.
//

import Foundation

protocol CreateService {
    associatedtype Model
    
    func create(_ model: Model, completion: @escaping (Result<Bool, Error>) -> Void)
}
