//
//  UpdateUserInfoUseCase.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import Foundation

protocol UpdateUserUseCase<Model, Entity> {
    
    associatedtype Model
    associatedtype Entity
    
    func update(
        userID: UUID,
        updateHandler: @escaping (UserEntity?) -> Void,
        onComplete: @Sendable @escaping (Error?) -> Void
    )
}

final class UpdateUserUseCaseImp: UpdateUserUseCase {
    
    typealias Model = User
    typealias Entity = UserEntity
    
    private let repository: (any UserRepository<User, UserEntity>)

    init(repository: some UserRepository<User, UserEntity>) {
        self.repository = repository
    
    }
    
    func update(
        userID: UUID,
        updateHandler: @escaping (UserEntity?) -> Void,
        onComplete: @Sendable @escaping (Error?) -> Void
    ) {
        repository.update(
            userID: userID,
            updateHandler: updateHandler,
            onComplete: onComplete
        )
    }
}
