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
        case add100DayPlansOfPlan
    }
    
    // MARK: Output
    enum Output {
        case showCreatePlanScene
        case showPlanWeekScene(Plan?)
        
        case startAnimation
        case stopAnimation
        case showToast(title: String?, message: String)
        case showKeepGoingMessage(title: String?, message: String?)
        
        case configureUI
        case showUserInfo(User?)
        case userDeleted
        case setViewsAndDelegate(planIsExist: Bool)
        case loadPlanQueries([PlanQuery])
        case loadPlan(Plan)
        case loadDayPlans([DayPlan])
        case showCompleteDayPlanCount(Int)
        case alertError(Error?)
        
    }
    
    private let output = PublishSubject<Output>()
    private let disposeBag = DisposeBag()
    
    // MARK: UseCases
    private let updateUserUseCase: any UpdateUserUseCase<User, UserEntity>
    private let fetchUserUseCase: any FetchUserUseCase<User, UserEntity>
    private let fetchPlanUseCase: any FetchPlanUseCase<Plan, PlanEntity>
    private let updatePlanUseCase: any UpdatePlanUseCase<Plan, PlanEntity>
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
        updatePlanUseCase: some UpdatePlanUseCase<Plan, PlanEntity>,
        deletePlanQueryUseCase: some DeletePlanUseCase<PlanQuery, PlanQueryEntity>,
        deletePlanUseCase: some DeletePlanUseCase<Plan, PlanEntity>
    ) {
        self.updateUserUseCase = updateUserUseCase
        self.fetchUserUseCase = fetchUserUseCase
        self.fetchPlanUseCase = fetchPlanUseCase
        self.updatePlanUseCase = updatePlanUseCase
        self.deletePlanQueryUseCase = deletePlanQueryUseCase
        self.deletePlanUseCase = deletePlanUseCase
    }
    
    func transform(input: PublishSubject<Input>) -> PublishSubject<Output> {
        input
            .observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .subscribe(with: self) { (owner, event) in
                switch event {
                case .viewDidLoad:
                    owner.output.onNext( .configureUI)
                    owner.checkPlanIsExist()
                    
                case .planCreated:
                    owner.output.onNext(.configureUI)
                    owner.checkPlanIsExist()
                    owner.output.onNext(.showToast(
                        title: StringKey.planCreatedTitle.localized(),
                        message: StringKey.planCreatedMessage.localized())
                    )
                    
                case .viewWillAppear:
                    owner.output.onNext(.startAnimation)
                    
                case .viewWillDisappear:
                    owner.output.onNext(.stopAnimation)
                    
                case .reloadAll:
                    owner.fetchPlanQueriesOfUser()
                    
                case .reloadPlan:
                    owner.fetchCurrentPlan()
                    
                case .createPlanButtonDidTapped:
                    owner.output.onNext(.showCreatePlanScene)
                    
                case .completedDayPlansButtonDidTapped:
                    owner.output.onNext(.showPlanWeekScene(owner.currentPlan))
                    
                case .fetchPlan(let planQuery):
                    owner.fetchPlan(planQuery.id)
                    
                case .deletePlan:
                    owner.removePlanQuery()
                    
                case .add100DayPlansOfPlan:
                    owner.add100DayPlansOfPlan()
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
    func loadImage(dayPlanID: UUID, completion: @escaping (Data?) -> Void) {
        fetchPlanUseCase.loadImageFromDocument(fileName: dayPlanID.uuidString) { data in
            completion(data)
        }
    }
}

extension HomeViewModel {
    
    private func checkPlanIsExist() {
        guard let userIDString = UserDefaults.standard.string(forKey: UserDefaultsKey.userID),
              let userID = UUID(uuidString: userIDString)
        else { return }
        
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
              let userID = UUID(uuidString: userIDString)
        else { return }
        
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
    
    private func fetchCurrentPlan() {
        if let currentPlanQueryString = UserDefaults.standard.string(forKey: UserDefaultsKey.currentPlan),
           let currentPlanID = UUID(uuidString: currentPlanQueryString) {
            fetchPlan(currentPlanID)
        } else {
            guard let firstPlanID = user?.planQueries.first?.id else { return }
            fetchPlan(firstPlanID)
        }
    }
    
    private func fetchPlan(_ id: UUID) {
        fetchPlanUseCase.fetch(key: id) { [weak self] plan in
            guard let _self = self else { return }
            _self.currentPlan = plan
            _self.output.onNext(.loadPlan(plan))
            
            _self.currentWeek = Calendar.current.dateComponents(
                [.weekdayOrdinal],
                from: plan.startDate,
                to: .now).weekdayOrdinal! + 1
            let dayPlans = _self.loadCurrentWeekDayPlans(plan)
            
            _self.output.onNext(.showUserInfo(_self.user))
            _self.output.onNext(.loadDayPlans(dayPlans))
            
            _self.checkLastCertifyingDate()
            _self.getCountCompletedDayPlans(with: plan.dayPlans)
        }
    }
    
    private func getCountCompletedDayPlans(with dayPlans: [DayPlan]) {
        let completeDayPlanCount = dayPlans
            .filter { $0.isComplete }.count
        output.onNext(.showCompleteDayPlanCount(completeDayPlanCount))
    }
    
    private func checkLastCertifyingDate() {
        let date = currentPlan?.lastCertifyingDate
        let lastCompletedDayPlanQuery = DateFormatter.convertToDateQuery(date)
        let endDateQuery = DateFormatter.convertToDateQuery(currentPlan?.endDate)
        
        if lastCompletedDayPlanQuery?.dateComponents == endDateQuery?.dateComponents {
            output.onNext(.showKeepGoingMessage(title: StringKey.congratulation.localized(), message: StringKey.keepGoingMessage.localized()))
        } else {
            let todayQuery = DateFormatter.convertToDateQuery(.now)
            
            let dateInterval = self.calculateDateInterval(firstQuery: lastCompletedDayPlanQuery, secondQuery: todayQuery)
            
            showMessage(using: dateInterval)
        }
    }
    
    private func showMessage(using dateInterval: Int) {
        if dateInterval <= 0 {
            print("오늘")
        } else if dateInterval == 1 {
            let message = StringKey.successTodayMessage.localized()
            output.onNext(.showToast(title: StringKey.noti.localized(), message: message))
        } else {
            let message =
            StringKey.failureTodayMessage.localized(with: "\(dateInterval)")
            output.onNext(.showToast(title: StringKey.noti.localized(), message: message))
        }
    }
    
    private func loadCurrentWeekDayPlans(_ plan: Plan) -> [DayPlan] {
        guard let currentWeek else {
            print("current Week 없음")
            return []
        }
        return filtered(plan.dayPlans, at: currentWeek)
    }
    
    private func filtered(_ dayPlans: [DayPlan], at week: Int) -> [DayPlan] {
        return dayPlans.filter { $0.week == week }
    }
    

    func calculateDateInterval(firstQuery: DateQuery?, secondQuery: DateQuery?) -> Int {
        guard let firstQuery, let secondQuery else { return 0 }
        
        let theNumberOfDaysPassed = Calendar.current.dateComponents([.day], from: firstQuery.date, to: secondQuery.date).day!
        
        return theNumberOfDaysPassed
    }

    private func add100DayPlansOfPlan() {
        guard let plan = currentPlan else { return }
        let planID = plan.id
        
        guard let _endDate = Calendar.current.date(byAdding: .day, value: 100, to: plan.endDate) else { return }
        
        let addingDayPlansDates = Array(0...100).map {
            Calendar.current.date(byAdding: .day, value: $0, to: plan.endDate)!
        }
  
        let dayPlans = addingDayPlansDates.map { date in
            DayPlan(
                id: UUID(), isRequired: true,
                isComplete: false, date: date,
                week: Calendar.current.dateComponents([.weekOfYear], from: plan.startDate, to: date).weekOfYear! + 1,
                content: nil, imageURL: nil
            )
        }
        
        updatePlanUseCase.update(
            entity: PlanEntity.self,
            key: planID,
            updateHandler: { entity in
                entity?.endDate = _endDate
                entity?.targetNumberOfDays += 100
                entity?.dayPlans.append(objectsIn: dayPlans.map { $0.toEntity() })
            },
            onComplete: { [weak self] error in
                if let error {
                    self?.output.onNext(.alertError(error))
                    return
                }
                self?.checkPlanIsExist()
            }
        )
    }
    
    private func removePlanQuery() {
        guard let planID = currentPlan?.id else { print("플랜이 존재하지 않음"); return }
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.currentPlan)

        deletePlanQueryUseCase.delete(
            entity: PlanQueryEntity.self,
            key: planID,
            onComplete: { [weak self] error in
                if let error {
                    self?.output.onNext(.alertError(error))
                    return
                }
                self?.deletePlan()
            }
        )
    }
    
    private func deletePlan() {
        guard let currentPlan else { print("플랜이 존재하지 않음"); return }
        
        deletePlanUseCase.delete(entity: PlanEntity.self, key: currentPlan.id) { realm, entity in
            guard let _entity = entity else { return }
            realm.delete(_entity.dayPlans)
            realm.delete(_entity)
        } onComplete: { [weak self] error in
            if let error {
                self?.output.onNext(.alertError(error))
                return
            }
            self?.checkPlanIsExist()
        }
    }
}
