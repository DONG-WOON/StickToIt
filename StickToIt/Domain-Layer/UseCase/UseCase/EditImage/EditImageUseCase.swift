//
//  EditImageUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/10/23.
//

import Foundation


protocol EditImageUseCase: EditService, CreateService, FetchService {
    func upload(data: Data?)
}

final class EditImageUseCaseImpl<Repository: PlanRepository<Plan, PlanEntity, PlanQuery>>: EditImageUseCase {

    typealias Model = ImageAsset
    typealias Query = ImageQuery
    typealias Repository = Repository
    
    let repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func fetchAll(completion: @escaping ([ImageAsset]) -> Void) {
    }
    
    func fetch(query: ImageQuery, completion: @escaping (ImageAsset) -> Void) {
    }
    
    func create(_ model: ImageAsset, completion: @escaping (Result<Bool, Error>) -> Void) {
        
    }
    
    func update() {
        
    }
    
    func upload(data: Data?) {
        
//        repository.fetch(query: Plan)
    }
}


