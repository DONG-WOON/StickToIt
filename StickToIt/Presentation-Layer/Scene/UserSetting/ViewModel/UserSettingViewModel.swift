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
        case userNameValidate(Bool)
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
            .subscribe(with: self) { (_self, event) in
                switch event {
                case .registerButtonDidTapped:
                    _self.register()
                case .textInput(text: let text):
                    _self.validate(text: text)
                }
            }
            .disposed(by: disposeBag)
        
        return output.asObserver()
    }
}

extension UserSettingViewModel {
    private func validate(text: String?) {
        guard let text, !text.isEmpty else {
            output.onNext(.validateError(" "))
            output.onNext(.userNameValidate(false))
            return
        }
        
        if text.contains(" ") || text.contains("\n") {
            output.onNext(.validateError("공백이나 줄바꿈 문자는 사용할 수 없습니다."))
            output.onNext(.userNameValidate(false))
            return
        }
                
        if text.count < 2 {
            output.onNext(.validateError("2자 이상으로 입력해주세요!"))
            output.onNext(.userNameValidate(false))
            return
        }
        
        if text.count > 20 {
            output.onNext(.validateError("20자 이하로 입력해주세요"))
            output.onNext(.userNameValidate(false))
            return
        }
    
        output.onNext(.validateError(nil))
        output.onNext(.userNameValidate(true))
        userNickname = text
    }
    
    private func register() {
        let user = User(id: UUID(), name: userNickname, planQueries: [])
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
