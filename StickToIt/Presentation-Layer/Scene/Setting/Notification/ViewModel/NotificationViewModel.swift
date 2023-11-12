//
//  NotificationViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 11/11/23.
//

import Foundation
import RxSwift

final class NotificationViewModel {
    
    enum Input {
        case viewDidLoad
        case viewWillDisappear
    }
    
    enum Output {
        case setUpTableView((isAllowed: Bool, time: Date?))
    }
    
    private let output = PublishSubject<Output>()
    private let localNotiIsAllowed = BehaviorSubject(value: false)
    private let localNotiDate = BehaviorSubject<Date>(value: .now)
    private let disposeBag = DisposeBag()
    private let fetchUserUseCase: (any FetchUserUseCase<User, UserEntity>)?
    
    init(fetchUserUseCase: some FetchUserUseCase<User, UserEntity>) {
        self.fetchUserUseCase = fetchUserUseCase
    }
    
    func transform(input: PublishSubject<Input>) -> PublishSubject<Output> {
        input
            .observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .subscribe(with: self) { owner, event in
                switch event {
                case .viewDidLoad:
                    owner.loadLocalNotificationIsAllowedAndDate()
                    
                case .viewWillDisappear:
                    owner.setUpLocalNotification()
                }
            }
            .disposed(by: disposeBag)
    
        return output
    }
}

extension NotificationViewModel {
    
    func setUpLocalNotification() {
        Observable.combineLatest(
            localNotiIsAllowed,
            localNotiDate
        )
        
        .subscribe(with: self) { owner, value in
            owner.setUpLocalNotification(value)
        }
        .disposed(by: disposeBag)
    }
    
    func switchChanged(_ isAllowed: Bool) {
        localNotiIsAllowed.onNext(isAllowed)
    }
    
    func dateChanged(_ date: Date) {
        localNotiDate.onNext(date)
    }
    
    func setUpLocalNotification(_ notiInfo: (isAllowed: Bool, time: Date)) {
        if notiInfo.isAllowed {
            NotificationManager.shared.deleteLocalNotification()
            
            let _time = notiInfo.time
            let _timeString = DateFormatter.formatToString(format: .time, from: _time)
            UserDefaults.standard.setValue(_timeString, forKey: UserDefaultsKey.localNotificationDate)
            UserDefaults.standard.setValue(true, forKey: UserDefaultsKey.localNotificationIsAllowed)
            
            NotificationManager.shared.setUpLocalNotification(time: _time)
        } else {
            UserDefaults.standard.setValue(false, forKey: UserDefaultsKey.localNotificationIsAllowed)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKey.localNotificationDate)
            
            NotificationManager.shared.deleteLocalNotification()
        }
    }
    
    func loadLocalNotificationIsAllowedAndDate() {
        let isAllowed = UserDefaults.standard.bool(forKey: UserDefaultsKey.localNotificationIsAllowed)
        let date = UserDefaults.standard.string(forKey: UserDefaultsKey.localNotificationDate) ?? ""
        let time = DateFormatter.formatToDate(format: .time, from: date)
        
        output.onNext(.setUpTableView((isAllowed, time)))
    }
}
