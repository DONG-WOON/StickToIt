//
//  UpdateUserInfoUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import Foundation

protocol UpdateUserUseCase<Entity, Model, ID> {
    associatedtype Entity
    associatedtype Model
    associatedtype ID
    
    func updateUserInfo(
        userID: UUID,
        updateHandler: @escaping (UserEntity) -> Void,
        onFailure: @Sendable @escaping (Error?) -> Void
    )
}

final class UpdateUserUseCaseImp: UpdateUserUseCase {
    
    typealias Entity = UserEntity
    typealias Model = User
    typealias ID = UUID
    
    private let repository: (any UserRepository<User, UserEntity, UUID>)

    init(repository: some UserRepository<User, UserEntity, UUID>) {
        self.repository = repository
    
    }
    
    func updateUserInfo(
        userID: UUID,
        updateHandler: @escaping (UserEntity) -> Void,
        onFailure: @Sendable @escaping (Error?) -> Void
    ) {
        repository.update(
            userID: userID,
            updateHandler: updateHandler,
            onFailure: onFailure
        )
       
    }
}
