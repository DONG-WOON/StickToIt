//
//  DiContainer.swift
//  StickToIt
//
//  Created by 서동운 on 10/27/23.
//

import Foundation

final class DIContainer {
    
    static let shared = DIContainer()
    
    lazy var databaseManager = DatabaseManagerImp()
    
    
    // MARK: UseCases
    
    func makeFetchPlanUseCase() -> some FetchPlanUseCase<Plan, PlanEntity> {
        FetchPlanUseCaseImp(repository: planRepository)
    }
    
    func makeCreatePlanUseCase() -> some CreatePlanUseCase<Plan, PlanEntity> {
        CreatePlanUseCaseImp(repository: planRepository)
    }
    
    func makeUpdatePlanUseCase() -> some UpdatePlanUseCase<Plan, PlanEntity> {
        UpdatePlanUseCaseImp(repository: planRepository)
    }
    
    func makeDeletePlanUseCase() -> some DeletePlanUseCase<Plan, PlanEntity> {
        DeletePlanUseCaseImp(repository: planRepository)
    }
    
    func makeDeletePlanQueryUseCase() -> some DeletePlanUseCase<PlanQuery, PlanQueryEntity> {
        DeletePlanQueryUseCaseImp(repository: planQueryRepository)
    }
    
    func makeFetchUserUseCase() -> some FetchUserUseCase<User, UserEntity> {
        FetchUserUseCaseImp(repository: userRepository)
    }
    
    func makeUpdateUserUseCase() -> some UpdateUserUseCase<User, UserEntity> {
        UpdateUserUseCaseImp(repository: userRepository)
    }
    
    func makeUpdateDayPlanUseCase() -> some UpdateDayPlanUseCase<DayPlan, DayPlanEntity> {
        UpdateDayPlanUseCaseImp(repository: dayPlanRepository)
    }
    
    
    
    // MARK: Repository
    
    lazy var planQueryRepository = makePlanQueryRepository()
    lazy var planRepository = makePlanRepository()
    lazy var userRepository = makeUserRepository()
    lazy var dayPlanRepository = makeDayPlanRepository()
    
    
    func makePlanRepository() -> any PlanRepository<Plan, PlanEntity> {
        PlanRepositoryImp(
            networkService: nil,
            databaseManager: databaseManager
        )
    }
    
    func makePlanQueryRepository() -> any PlanRepository<PlanQuery, PlanQueryEntity> {
        PlanQueryRepositoryImp(
            networkService: nil,
            databaseManager: databaseManager
        )
    }
    
    func makeUserRepository() -> any UserRepository<User, UserEntity> {
        UserRepositoryImp(
            networkService: nil,
            databaseManager: databaseManager
        )
    }
    
    func makeDayPlanRepository() -> any DayPlanRepository<DayPlan, DayPlanEntity>  {
        DayPlanRepositoryImp(
            networkService: nil,
            databaseManager: databaseManager
        )
    }
    
    // MARK: ViewModel
    
    static func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            updateUserUseCase: shared.makeUpdateUserUseCase(),
            fetchUserUseCase: shared.makeFetchUserUseCase(),
            fetchPlanUseCase: shared.makeFetchPlanUseCase(),
            updatePlanUseCase: shared.makeUpdatePlanUseCase(),
            deletePlanQueryUseCase: shared.makeDeletePlanQueryUseCase(),
            deletePlanUseCase: shared.makeDeletePlanUseCase()
        )
    }
    
    static func makeCreatePlanViewModel() -> CreatePlanViewModel {
        CreatePlanViewModel(
            planUseCase: shared.makeCreatePlanUseCase(),
            userUseCase: shared.makeUpdateUserUseCase()
        )
    }
    
    static func makeDayPlanViewModel(dayPlan: DayPlan) -> DayPlanViewModel {
        DayPlanViewModel(
            dayPlan: dayPlan,
            updateDayPlanUseCase: shared.makeUpdateDayPlanUseCase()
        )
    }
    
    static func makeCalendarViewModel() -> CalendarViewModel {
        CalendarViewModel(
            planRepository: shared.planRepository,
            userRepository: shared.userRepository
        )
    }
    
    static func makeUserSettingViewModel() -> UserSettingViewModel {
        UserSettingViewModel(repository: shared.userRepository)
    }
    
    static func makeUserEditingViewModel() -> UserEditingViewModel {
        UserEditingViewModel(repository: shared.userRepository)
    }
    
    }
}
