//
//  UserEditingViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/30/23.
//

import UIKit
import RxSwift

final class UserEditingViewModel {
    
    enum Input {
        case viewDidLoad
        case editButtonDidTapped
        case textInput(text: String?)
    }
    
    enum Output {
        case updateNickname(String)
        case userNicknameValidate(Bool)
        case validateError(String?)
        case completeEditing
        case showError(Error)
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
                case .viewDidLoad:
                    owner.fetchUserInfo()
                case .editButtonDidTapped:
                    owner.complete()
                case .textInput(text: let text):
                    owner.validate(text: text)
                }
            }
            .disposed(by: disposeBag)
        
        return output.asObserver()
    }
}

extension UserEditingViewModel {
    
    private func fetchUserInfo() {
        guard let userIDString = UserDefaults.standard.string(
            forKey: UserDefaultsKey.userID
        ), let userID = UUID(uuidString: userIDString) else { return }
        
        repository.fetch(key: userID) { result in
            switch result {
            case .success(let user):
                self.userNickname = user.nickname
                self.output.onNext(.updateNickname(user.nickname))
            case .failure(let error):
                self.output.onNext(.showError(error))
            }
        }
    }
    
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
    
    private func complete() {
        guard let userIDString = UserDefaults.standard.string(
            forKey: UserDefaultsKey.userID
        ), let userID = UUID(uuidString: userIDString) else { return }
        
        repository.update(userID: userID) { [userNickname] entity in
            entity?.nickname = userNickname
        } onComplete: { [weak self, userNickname] error in
            if let error {
                self?.output.onNext(.showError(error))
                return
            }
            NotificationCenter.default.post(name: .updateNickname, object: nil, userInfo: [NotificationKey.nickname: userNickname])
            self?.output.onNext(.completeEditing)
        }
    }
}
