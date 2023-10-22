//
//  UserInfoUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import Foundation

protocol UserInfoUseCase {
    func fetchUserInfo(key: UUID, completion: @escaping (User) -> Void)
    func updateUserInfo(userID: UUID, updateHandler: @escaping (UserEntity) -> Void, onFailure: @escaping (Error?) -> Void)
}

final class UserInfoUseCaseImpl<
    Repository: UserRepository<User, UserEntity, UUID>
>: UserInfoUseCase {
    
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
    
    func updateUserInfo(userID: UUID, updateHandler: @escaping (UserEntity) -> Void, onFailure: @escaping (Error?) -> Void) {
        repository.update(userID: userID, updateHandler: updateHandler, onFailure: onFailure)
    }
}
