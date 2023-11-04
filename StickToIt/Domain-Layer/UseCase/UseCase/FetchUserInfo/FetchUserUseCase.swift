//
//  FetchUserUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/27/23.
//

import Foundation

protocol FetchUserUseCase<Model, Entity> {
    
    associatedtype Model
    associatedtype Entity
    
    func fetchUserInfo(
        key: UUID,
        completion: @escaping (Model) -> Void
    )
}


final class FetchUserUseCaseImp: FetchUserUseCase {
    
    typealias Model = User
    typealias Entity = UserEntity
    
    private let repository: (any UserRepository<User, UserEntity>)

    init(repository: some UserRepository<User, UserEntity>) {
        self.repository = repository
    
    }
    
    func fetchUserInfo(
        key: UUID,
        completion: @escaping (Model) -> Void
    ) {
        
        repository.fetch(key: key) { result in
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let failure):
                print(failure)
            }
        }
    }
}
