//
//  FetchUserInfoUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import Foundation

protocol FetchUserInfoUseCase {
    func fetchUserInfo(key: UUID, completion: @escaping (User) -> Void)
    
}

final class FetchUserInfoUseCaseImpl<
    Repository: UserRepository<User, UserEntity, UUID>
>: FetchUserInfoUseCase {
    
    typealias Entity = UserEntity
    typealias Model = User
    typealias ID = UUID
    
    private let repository: Repository

    init(repository: Repository) {
        self.repository = repository
    
    }
    
    func fetchUserInfo(key: ID, completion: @escaping (User) -> Void) {
        
        let result = repository.fetch(key: key)
        switch result {
        case .success(let user):
            completion(user)
        case .failure(let failure):
            print(failure)
        }
    }
}
