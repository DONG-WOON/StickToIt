//
//  DataManagementViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/30/23.
//

import Foundation
import RxSwift

//
//  SettingViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/30/23.
//

import Foundation
import RxSwift

final class DataManagementViewModel {
    
    enum Row: Int, CaseIterable {
        case backup
        case deleteUser
        
        var title: String {
            switch self {
            case .backup:
                return "백업(지원 예정)"
            case .deleteUser:
                return "계정 삭제"
            }
        }
    }
    
    enum Input {
        case backup
        case deleteUser
    }
    
    enum Output {
        case completeBackUP
        case completeDeleteUser
        case showError(Error)
    }
    
    private let repository: any UserRepository<User, UserEntity>
    
    private let output = PublishSubject<Output>()
    private let disposeBag = DisposeBag()
    
    init(repository: some UserRepository<User, UserEntity>) {
        self.repository = repository
    }
    
    func transform(input: PublishSubject<Input>) -> PublishSubject<Output> {
        input
            .subscribe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .subscribe(with: self) { _self, event in
                switch event {
                case .backup:
                    _self.backup()
                case .deleteUser:
                    _self.deleteUser()
                }
            }
            .disposed(by: disposeBag)
        
        return output.asObserver()
    }
}

extension DataManagementViewModel {
    private func backup() {
        
    }
    
    private func deleteUser() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.userID)
        repository.deleteAll { [weak self] error in
            if let error {
                self?.output.onNext(.showError(error))
                return
            }
            self?.output.onNext(.completeDeleteUser)
        }
    }
}

// MARK: TableView
extension DataManagementViewModel {

    
    var numberOfRowsInSection: Int {
        Row.allCases.count
    }
    
    func rowTitle(at indexPath: IndexPath) -> String? {
        if let row = Row(rawValue: indexPath.row) {
            return row.title
        } else {
            return nil
        }
    }
    
    func isDeleteUser(at indexPath: IndexPath) -> Bool {
        indexPath.row == 1
    }
    
    func selectedRowAt(_ indexPath: IndexPath, completion: (Row) -> Void) {
        
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            completion(.backup)
        case IndexPath(row: 1, section: 0):
            completion(.deleteUser)
        default:
            return
        }
    }
}
