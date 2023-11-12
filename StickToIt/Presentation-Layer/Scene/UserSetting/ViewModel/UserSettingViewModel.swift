//
//  UserSettingViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/17/23.
//

import Foundation
import RxSwift

final class UserSettingViewModel {
    
    enum Input {
        case registerButtonDidTapped
        case textInput(text: String?)
    }
    
    enum Output {
        case userNicknameValidate(Bool)
        case validateError(String?)
        case completeUserRegistration
    }
    
    private var userNickname: String = String()
    private let repository: any UserRepository<User, UserEntity>
    private let output = PublishSubject<Output>()
    private let disposeBag = DisposeBag()
    
    init(repository: some UserRepository<User, UserEntity>) {
        self.repository = repository
    }
    
    func transform(input: PublishSubject<Input>) -> PublishSubject<Output> {
        input
            .observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .subscribe(with: self) { (owner, event) in
                switch event {
                case .registerButtonDidTapped:
                    owner.register()
                case .textInput(text: let text):
                    owner.validate(text: text)
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

extension UserSettingViewModel {
    private func validate(text: String?) {
        guard let text, !text.isEmpty else {
            output.onNext(.validateError(" "))
            output.onNext(.userNicknameValidate(false))
            return
        }
        
        if text.contains(" ") || text.contains("\n") {
            output.onNext(.validateError(StringKey.validateLineBreak.localized()))
            output.onNext(.userNicknameValidate(false))
            return
        }
                
        if text.count < 2 {
            output.onNext(.validateError(StringKey.overTwoCharacter.localized()))
            output.onNext(.userNicknameValidate(false))
            return
        }
        
        if text.count > 20 {
            output.onNext(.validateError(StringKey.lessThan20.localized()))
            output.onNext(.userNicknameValidate(false))
            return
        }
    
        output.onNext(.validateError(nil))
        output.onNext(.userNicknameValidate(true))
        userNickname = text
    }
    
    private func register() {
        let user = User(id: UUID(), nickname: userNickname, planQueries: [])
        repository.create(model: user) { [weak self] result in
            switch result {
            case .success:
                UserDefaults.standard.setValue(user.id.uuidString, forKey: UserDefaultsKey.userID)
                self?.output.onNext(.completeUserRegistration)
            case .failure(let error):
                print(error)
            }
        }
    }
}
