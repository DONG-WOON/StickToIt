//
//  FetchUserUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/27/23.
//

import Foundation

protocol FetchUserUseCase {
    func fetchUserInfo(
        key: UUID,
        completion: @escaping (User) -> Void
    )
}


final class FetchUserUseCaseImp: FetchUserUseCase {
    
    typealias Entity = UserEntity
    typealias Model = User
    typealias ID = UUID
    
    private let repository: (any UserRepository<User, UserEntity, UUID>)

    init(repository: some UserRepository<User, UserEntity, UUID>) {
        self.repository = repository
    
    }
    
    func fetchUserInfo(
        key: ID,
        completion: @escaping (User) -> Void
    ) {
        
        let result = repository.fetch(key: key)
        switch result {
        case .success(let user):
            completion(user)
        case .failure(let failure):
            print(failure)
        }
    }
}
