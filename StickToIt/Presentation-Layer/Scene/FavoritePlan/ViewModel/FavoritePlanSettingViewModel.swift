//
//  FavoritePlanSettingViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import Foundation
import RxSwift

final class FavoritePlanSettingViewModel {
    
    var planQueries = PublishSubject<[PlanQuery]>()
    
    private let useCase: FetchUserInfoUseCase
    
    init(useCase: FetchUserInfoUseCase) {
        self.useCase = useCase
    }

    func fetchPlanQueries() {
        guard let userIDString = UserDefaults.standard.string(forKey: Const.Key.userID.rawValue), let userID = UUID(uuidString: userIDString) else { return }

        useCase.fetchUserInfo(key: userID) { [weak self] user in
            self?.planQueries.onNext(user.planQueries)
        }
    }
}
