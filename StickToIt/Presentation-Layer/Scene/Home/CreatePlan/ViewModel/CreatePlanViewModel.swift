//
//  CreatePlanViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/3/23.
//

import Foundation
import RxSwift

final class CreatePlanViewModel {
    
    enum Input {
        case viewDidLoad
        case createPlanButtonDidTapped
        case planNameTextInput(String)
        case startDateSelected(Int)
        case endDateIsSelected(date: Date)
        case calendarButtonDidTapped
    }
    
    enum Output {
        case configureUI
        case planIsValidated(Bool)
        case updateEndDateTitle(with: String)
        case createPlanCompleted
        case showAlert(message: String)
        case presentCalendar(withStartDate: Date, endDate: Date)
    }
    
    // MARK: Properties
    
    private let planName = BehaviorSubject(value: "")
    private let startDate = BehaviorSubject(value: Date.now)
    private let endDate = BehaviorSubject(value: Date.now.addDays(2))
    private let planIsValidated = BehaviorSubject(value: false)
    private let output = PublishSubject<Output>()
    private let disposeBag = DisposeBag()
    
    // MARK: UseCases
    private let planUseCase: any CreatePlanUseCase<Plan, PlanEntity>
    private let userUseCase: any UpdateUserUseCase<User, UserEntity>
    
    // MARK: Life Cycle
    init(
        planUseCase: some CreatePlanUseCase<Plan, PlanEntity>,
        userUseCase: some UpdateUserUseCase<User, UserEntity>
    ) {
        self.planUseCase = planUseCase
        self.userUseCase = userUseCase
    }
    
    func transform(input: PublishSubject<Input>) -> PublishSubject<Output> {
        
        input
            .observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .subscribe(with: self) { owner, input in
                switch input {
                case .viewDidLoad:
                    owner.output.onNext(.configureUI)
                    
                case .planNameTextInput(let planName):
                    owner.updatePlanName(planName)
                    
                case .endDateIsSelected(let endDate):
                    owner.updatePlanEndDate(endDate)
                    
                case .createPlanButtonDidTapped:
                    owner.createPlan()
                    
                case .startDateSelected(let segmentIndex):
                    owner.updatePlanStartDate(index: segmentIndex)
                    
                case .calendarButtonDidTapped:
                    owner.showCalendar()
                }
            }
            .disposed(by: disposeBag)
        
        return output.asObserver()
    }
}

// MARK: Data Transfer
extension CreatePlanViewModel {
    func showCalendar() {
        do {
            let startDate = try startDate.value()
            let endDate = try endDate.value()
            
            output.onNext(.presentCalendar(withStartDate: startDate, endDate: endDate))
        } catch {
            print(error)
        }
    }
}

extension CreatePlanViewModel {
    
    func updatePlanName(_ planName: String) {
        self.planName.onNext(planName)
        output.onNext(.planIsValidated(!planName.isEmpty))
    }
    
    func updatePlanStartDate(index: Int) {
        switch index {
        case 0:
            self.startDate.onNext(.now)
            self.endDate.onNext(.now.addDays(2))
        case 1:
            self.startDate.onNext(.now.addDays(1))
            self.endDate.onNext(.now.addDays(3))
        default:
            return
        }
    }
    
    func updatePlanEndDate(_ date: Date) {
        self.endDate.onNext(date)
        let endDateString = DateFormatter.getFullDateString(from: date)
        output.onNext(.updateEndDateTitle(with: endDateString))
    }
    
    func createPlan() {
        do {
            let startDate = try startDate.value()
            let endDate = try endDate.value()
            let planName = try planName.value()
            
            let planDuration = Calendar
                .current.dateComponents(
                    [.day], from: startDate,
                    to: endDate
                ).day!
            
            let dayPlanDates = Array(0...planDuration + 1)
                .map { startDate.addDays($0) }
            
            let dayPlans = dayPlanDates.map { date in
                let week = Calendar
                    .current.dateComponents(
                        [.weekOfYear],
                        from: startDate, to: date
                    ).weekOfYear! + 1
                
                return DayPlan(
                    id: UUID(), isRequired: true,
                    isComplete: false, date: date,
                    week: week,
                    content: nil,
                    imageURL: nil
                )
            }
            
            let plan = Plan(
                id: UUID(),
                name: planName,
                targetNumberOfDays: planDuration + 1,
                startDate: startDate,
                endDate: endDate,
                dayPlans: dayPlans
            )
            
            
            planUseCase.create(plan) { [weak self] result in
                guard let _self = self else { return }
                switch result {
                case .success:
                    _self.addPlanQueryToUser(using: plan)
                case .failure:
                    _self.output.onNext(.showAlert(message: StringKey.createPlanErrorMessage.localized()))
                }
            }
        } catch {
            print(error)
        }
    }
    
    func addPlanQueryToUser(using plan: Plan) {
        let planQuery = PlanQuery(id: plan.id, planName: plan.name)
        
        guard let userIDString = UserDefaults.standard.string(
            forKey: UserDefaultsKey.userID
        ), let userID = UUID(uuidString: userIDString) else {
            return
        }
        
        self.update(planQuery: planQuery, of: userID)
    }
    
    private func update(
        planQuery: PlanQuery,
        of user: UUID
    ) {
        userUseCase.update(
            userID: user,
            updateHandler: { $0?.planQueries.append(planQuery.toEntity()) },
            onComplete: {[weak self] error in
                if let error {
                    return
                    //목표를 생성하고 저장소에도 저장이 되었지만, 사용자의 목표리스트에는 추가가 안된경우. 어떻게 하지?
                }
                
                UserDefaults.standard.setValue(
                    planQuery.id.uuidString,
                    forKey: UserDefaultsKey.currentPlan
                )
                
                self?.output.onNext(.createPlanCompleted)
            }
        )
    }
}
