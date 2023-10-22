//
//  HomeViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel<PlanUseCase: FetchPlanUseCase>
where PlanUseCase.Model == Plan, PlanUseCase.Query == PlanQuery
{
    enum Input {
        case createPlanButtonDidTapped
        case planWeekButtonDidTapped
        
        case viewDidLoad
        case viewWillAppear
        case viewWillDisappear
        case reloadAll
        case reloadPlan
        case fetchPlan(PlanQuery)
    }
    
    enum Output {
        case showCreatePlanScene
        case showPlanWeekScene(Int)
        case startAnimation
        case stopAnimation
        
        case setViewsAndDelegate(planIsExist: Bool)
        case loadPlanQueries([PlanQuery])
        case loadPlan(Plan)
        case loadDayPlans([DayPlan])
        case loadAchievementProgress(Double)
    }
    
    private let userInfoUseCase: UserInfoUseCase
    private let planUseCase: PlanUseCase
    private let mainQueue: DispatchQueue
    private let output = PublishSubject<Output>()
    private let disposeBag = DisposeBag()
    
    var currentWeek: Int?
    var currentPlanCount: Int?
    
    init(
        userInfoUseCase: UserInfoUseCase,
        planUseCase: PlanUseCase,
        mainQueue: DispatchQueue = .main
    ) {
        self.userInfoUseCase = userInfoUseCase
        self.planUseCase = planUseCase
        self.mainQueue = mainQueue
    }
    
    func transform(input: PublishSubject<Input>) -> PublishSubject<Output> {
        input
            .subscribe(with: self) { (_self, event) in
                switch event {
                case .viewDidLoad:
                    _self.checkPlanIsExist()
                    
                case .viewWillAppear:
                    _self.output.onNext(.startAnimation)
                    
                case .viewWillDisappear:
                    _self.output.onNext(.stopAnimation)
                    
                case .reloadAll:
                    _self.fetchPlanQueriesOfUser()
                    
                case .reloadPlan:
                    _self.fetchCurrentPlan()
                    
                case .createPlanButtonDidTapped:
                    _self.output.onNext(.showCreatePlanScene)
                    
                case .planWeekButtonDidTapped:
                    _self.output.onNext(.showPlanWeekScene(1))
                    
                case .fetchPlan(let planQuery):
                    _self.fetchPlan(planQuery)
                }
            }
            .disposed(by: disposeBag)
        
        return output.asObserver()
    }
    
    func loadImage(dayPlanID: UUID, completion: @escaping (Data?) -> Void) {
        planUseCase.loadImageFromDocument(fileName: dayPlanID.uuidString) { data in
            completion(data)
        }
    }
}

extension HomeViewModel {
    
    private func fetchCurrentPlan() {
        if let currentPlanQueryString = UserDefaults.standard.string(forKey: Const.Key.currentPlan.rawValue), let currentPlanID = UUID(uuidString: currentPlanQueryString) {
            
            let currentPlanQuery = PlanQuery(planID: currentPlanID, planName: "")
            
            fetchPlan(currentPlanQuery)
        }
    }
    
    private func checkPlanIsExist() {
        guard let userIDString = UserDefaults.standard.string(forKey: Const.Key.userID.rawValue),
              let userID = UUID(uuidString: userIDString) else {
            return
        }
        
        userInfoUseCase.fetchUserInfo(key: userID) { [weak self] user in
            let planQueries = user.planQueries
            
            if planQueries.count > 0 {
                self?.output.onNext(.setViewsAndDelegate(planIsExist: true))
            } else {
                self?.output.onNext(.setViewsAndDelegate(planIsExist: false))
            }
        }
    }
    
    private func fetchPlanQueriesOfUser() {
        guard let userIDString = UserDefaults.standard.string(forKey: Const.Key.userID.rawValue),
                let userID = UUID(uuidString: userIDString) else {
            return
        }
      
        userInfoUseCase.fetchUserInfo(key: userID) { [weak self] user in
            
            let planQueries = user.planQueries
            self?.currentPlanCount = planQueries.count
            if !planQueries.isEmpty {
                self?.output.onNext(.loadPlanQueries(planQueries))
                self?.fetchCurrentPlan()
            }
        }
    }
    
    private func fetchPlan(_ query: PlanQuery) {
        planUseCase.fetch(query: query) { [weak self] plan in
            guard let _self = self else { return }
            
            _self.output.onNext(.loadPlan(plan))
            
            _self.currentWeek = Calendar.current.dateComponents(
                [.weekdayOrdinal],
                from: plan.startDate,
                to: .now).weekdayOrdinal! + 1
            let dayPlans = _self.loadCurrentWeekDayPlans(plan)
            _self.output.onNext(.loadDayPlans(dayPlans))
            
            _self.computeAchievementProgress(of: dayPlans)
        }
    }
    
    private func computeAchievementProgress(of dayPlans: [DayPlan]) {
        
        let requiredDayPlanCount = dayPlans
            .filter { $0.isRequired }.count
        let completeDayPlanCount = dayPlans
            .filter { $0.isComplete }.count
        let progress = Double(completeDayPlanCount) / Double(requiredDayPlanCount)
        
        output.onNext(.loadAchievementProgress(progress))
    }
    
    private func loadCurrentWeekDayPlans(_ plan: Plan) -> [DayPlan] {
        guard let currentWeek else {
            print("current Week 없음")
            return []
        }
        return filtered(plan.dayPlans, at: currentWeek)
    }
    
    private func filtered(_ dayPlans :[DayPlan], at week: Int) -> [DayPlan] {
        return dayPlans.filter { $0.week == week }
    }
}
