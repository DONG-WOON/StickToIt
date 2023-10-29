//
//  HomeViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel {
    
    // MARK: Input
    enum Input {
        case createPlanButtonDidTapped
        case completedDayPlansButtonDidTapped
        
        case viewDidLoad
        case viewWillAppear
        case viewWillDisappear
        case reloadAll
        case reloadPlan
        case fetchPlan(PlanQuery)
        case planCreated
        case deletePlan
    }
    
    // MARK: Output
    enum Output {
        case showCreatePlanScene
        case showPlanWeekScene(Plan?)
        
        case startAnimation
        case stopAnimation
        case showToast(title: String?, message: String)
        
        case configureUI
        case showUserInfo(User?)
        case userDeleted
        case setViewsAndDelegate(planIsExist: Bool)
        case loadPlanQueries([PlanQuery])
        case loadPlan(Plan)
        case loadDayPlans([DayPlan])
        case loadAchievementProgress(Double)
        case showCompleteDayPlanCount(Int)
    }
    
    private let output = PublishSubject<Output>()
    private let disposeBag = DisposeBag()
    
    // MARK: UseCases
    private let updateUserUseCase: any UpdateUserUseCase<User, UserEntity>
    private let fetchUserUseCase: any FetchUserUseCase<User, UserEntity>
    private let fetchPlanUseCase: any FetchPlanUseCase<Plan, PlanEntity>
    private let deletePlanQueryUseCase: any DeletePlanUseCase<PlanQuery, PlanQueryEntity>
    private let deletePlanUseCase: any DeletePlanUseCase<Plan, PlanEntity>
    
    
    // MARK: Inner Properties
    
    private var user: User?
    private var currentWeek: Int?
    private var currentPlan: Plan?
    
    var currentPlanCount: Int?
    
    // MARK: Life Cycle
    
    init(
        updateUserUseCase: some UpdateUserUseCase<User, UserEntity>,
        fetchUserUseCase: some FetchUserUseCase<User, UserEntity>,
        fetchPlanUseCase: some FetchPlanUseCase<Plan, PlanEntity>,
        deletePlanQueryUseCase: some DeletePlanUseCase<PlanQuery, PlanQueryEntity>,
        deletePlanUseCase: some DeletePlanUseCase<Plan, PlanEntity>
    ) {
        self.updateUserUseCase = updateUserUseCase
        self.fetchUserUseCase = fetchUserUseCase
        self.fetchPlanUseCase = fetchPlanUseCase
        self.deletePlanQueryUseCase = deletePlanQueryUseCase
        self.deletePlanUseCase = deletePlanUseCase
    }
    
    func transform(input: PublishSubject<Input>) -> PublishSubject<Output> {
        input
            .subscribe(with: self) { (_self, event) in
                switch event {
                case .viewDidLoad:
                    _self.output.onNext( .configureUI)
                    _self.checkPlanIsExist()
                    
                case .planCreated:
                    _self.output.onNext(.configureUI)
                    _self.checkPlanIsExist()
                    _self.output.onNext(.showToast(title: "목표생성완료", message: "목표가 생성되었습니다.\n 열심히 달성해보세요!"))
                    
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
                    
                case .completedDayPlansButtonDidTapped:
                    _self.output.onNext(.showPlanWeekScene(_self.currentPlan))
                    
                case .fetchPlan(let planQuery):
                    _self.fetchPlan(planQuery)
                    
                case .deletePlan:
                    _self.deletePlan()
                }
            }
            .disposed(by: disposeBag)
        
        return output.asObserver()
    }
    
    func loadImage(dayPlanID: UUID, completion: @escaping (Data?) -> Void) {
        fetchPlanUseCase.loadImageFromDocument(fileName: dayPlanID.uuidString) { data in
            completion(data)
        }
    }
}

extension HomeViewModel {
    
    private func fetchCurrentPlan() {
        if let currentPlanQueryString = UserDefaults.standard.string(forKey: UserDefaultsKey.currentPlan), let currentPlanID = UUID(uuidString: currentPlanQueryString) {
            
            let currentPlanQuery = PlanQuery(id: currentPlanID, planName: "")
            
            fetchPlan(currentPlanQuery)
        }
    }
    
    private func checkPlanIsExist() {
        guard let userIDString = UserDefaults.standard.string(forKey: UserDefaultsKey.userID),
              let userID = UUID(uuidString: userIDString) else {
            return
        }
        
        fetchUserUseCase.fetchUserInfo(key: userID) { [weak self] user in
            let planQueries = user.planQueries
            
            if planQueries.count > 0 {
                self?.output.onNext(.setViewsAndDelegate(planIsExist: true))
            } else {
                self?.output.onNext(.setViewsAndDelegate(planIsExist: false))
                
                self?.output.onNext(.showUserInfo(user))
            }
        }
    }
    
    private func fetchPlanQueriesOfUser() {
        guard let userIDString = UserDefaults.standard.string(forKey: UserDefaultsKey.userID),
                let userID = UUID(uuidString: userIDString) else {
            return
        }
        
        fetchUserUseCase.fetchUserInfo(key: userID) { [weak self] user in
            self?.user = user
            
            let planQueries = user.planQueries
            self?.currentPlanCount = planQueries.count
            if !planQueries.isEmpty {
                self?.output.onNext(.loadPlanQueries(planQueries))
                self?.fetchCurrentPlan()
            }
        }
    }
    
    private func fetchPlan(_ query: PlanQuery) {
        fetchPlanUseCase.fetch(key: query.id) { [weak self] plan in
            guard let _self = self else { return }
            _self.currentPlan = plan
            _self.output.onNext(.loadPlan(plan))
            
            _self.currentWeek = Calendar.current.dateComponents(
                [.weekdayOrdinal],
                from: plan.startDate,
                to: .now).weekdayOrdinal! + 1
            let dayPlans = _self.loadCurrentWeekDayPlans(plan)
            
            _self.computeAchievementProgress(of: dayPlans)
            _self.output.onNext(.showUserInfo(_self.user))
            _self.output.onNext(.loadDayPlans(dayPlans))
            _self.completedDayPlansCount(plan.dayPlans)
        }
    }
    
    private func completedDayPlansCount(_ dayPlans: [DayPlan]) {
        let completeDayPlanCount = dayPlans
            .filter { $0.isComplete }.count
        output.onNext(.showCompleteDayPlanCount(completeDayPlanCount))
    }
    
    private func computeAchievementProgress(of dayPlans: [DayPlan]) {
        
        let completedDayPlans = dayPlans.filter { $0.isComplete == true }
        
        guard let lastCompletedDayPlan = completedDayPlans.sorted(by: { $0.date < $1.date }).last else { return }
        
        let lastCompletedDayPlanQuery = DateFormatter.convertToDateQuery(lastCompletedDayPlan.date)
        let todayQuery = DateFormatter.convertToDateQuery(.now)
//        self.useDateQuery(firstQuery: lastCompletedDayPlanQuery, secondQuery: todayQuery)
        
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
    
//
//
//
//        updateUserUseCase.updateUserInfo(userID: user._id) { [currentPlan] entity in
//            guard
//                let _id = currentPlan?._id,
//                let index = entity.planQueries.firstIndex(where: { query in query._id == _id })
//            else { return }
//
//            entity.planQueries.remove(at: index)
//        } onFailure: { [weak self] error in
//            if let error {
//                print(error)
//                return
//            }
//            UserDefaults.standard.removeObject(forKey: Const.Key.currentPlan.rawValue)
//            self?.output.onNext(.userDeleted)
//        }
//    }
}
